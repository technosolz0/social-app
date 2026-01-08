from celery import shared_task
import logging
import requests
from django.conf import settings
from django.utils import timezone
from .models import PushToken, Notification, NotificationPreference

logger = logging.getLogger(__name__)

# FCM Server Key - should be in settings
FCM_SERVER_KEY = getattr(settings, 'FCM_SERVER_KEY', None)
FCM_URL = 'https://fcm.googleapis.com/fcm/send'


@shared_task
def send_push_notification(user_id, title, message, data=None, notification_type='system'):
    """
    Send push notification to user via FCM
    """
    try:
        # Get user's active push tokens
        push_tokens = PushToken.objects.filter(
            user_id=user_id,
            is_active=True
        ).exclude(token='')

        if not push_tokens.exists():
            logger.info(f"No active push tokens found for user {user_id}")
            return

        # Check user preferences for this notification type
        try:
            preferences = NotificationPreference.objects.get(user_id=user_id)
            should_send_push = _should_send_push_notification(preferences, notification_type)
            if not should_send_push:
                logger.info(f"Push notification blocked by user preferences for user {user_id}")
                return
        except NotificationPreference.DoesNotExist:
            # Default to sending if no preferences set
            pass

        # Check quiet hours
        if _is_in_quiet_hours(user_id):
            logger.info(f"Notification blocked by quiet hours for user {user_id}")
            return

        # Create notification record
        notification = Notification.objects.create(
            recipient_id=user_id,
            notification_type=notification_type,
            title=title,
            message=message,
            data=data or {},
            sent_via_push=True,
        )

        # Send to each device
        success_count = 0
        for push_token in push_tokens:
            if _send_fcm_notification(push_token.token, title, message, data):
                success_count += 1
                push_token.last_used = timezone.now()
                push_token.save()

        logger.info(f"Sent push notification to {success_count}/{push_tokens.count()} devices for user {user_id}")

    except Exception as e:
        logger.error(f"Error sending push notification to user {user_id}: {e}")


def _send_fcm_notification(token, title, message, data=None):
    """
    Send notification via FCM
    """
    if not FCM_SERVER_KEY:
        logger.warning("FCM_SERVER_KEY not configured")
        return False

    headers = {
        'Authorization': f'key={FCM_SERVER_KEY}',
        'Content-Type': 'application/json',
    }

    payload = {
        'to': token,
        'notification': {
            'title': title,
            'body': message,
            'sound': 'default',
            'badge': '1',
        },
        'data': data or {},
        'priority': 'high',
    }

    try:
        response = requests.post(FCM_URL, json=payload, headers=headers, timeout=10)
        response_data = response.json()

        if response.status_code == 200:
            if response_data.get('success') == 1:
                return True
            else:
                # Token might be invalid, mark as inactive
                error = response_data.get('results', [{}])[0].get('error')
                if error in ['InvalidRegistration', 'NotRegistered', 'InvalidPackageName']:
                    PushToken.objects.filter(token=token).update(is_active=False)
                logger.warning(f"FCM error for token {token[:20]}...: {error}")
        else:
            logger.error(f"FCM HTTP error: {response.status_code}")

    except Exception as e:
        logger.error(f"Error sending FCM notification: {e}")

    return False


def _should_send_push_notification(preferences, notification_type):
    """
    Check if push notification should be sent based on user preferences
    """
    # Map notification types to preference fields
    type_mapping = {
        'like': 'push_likes',
        'comment': 'push_comments',
        'follow': 'push_follows',
        'mention': 'push_mentions',
        'gift': 'push_gifts',
        'badge': 'push_badges',
        'system': 'push_system',
    }

    preference_field = type_mapping.get(notification_type, 'push_system')
    return getattr(preferences, preference_field, True)


def _is_in_quiet_hours(user_id):
    """
    Check if current time is within user's quiet hours
    """
    try:
        preferences = NotificationPreference.objects.get(user_id=user_id)
        if not preferences.quiet_hours_enabled:
            return False

        now = timezone.now().time()
        start = preferences.quiet_hours_start
        end = preferences.quiet_hours_end

        if start and end:
            if start <= end:
                # Same day range
                return start <= now <= end
            else:
                # Overnight range
                return now >= start or now <= end

    except NotificationPreference.DoesNotExist:
        pass

    return False


@shared_task
def send_email_notification(user_id, subject, message, html_message=None):
    """
    Send email notification to user
    """
    from django.core.mail import send_mail
    from apps.users.models import CustomUser

    try:
        user = CustomUser.objects.get(id=user_id)

        # Check email preferences
        try:
            preferences = NotificationPreference.objects.get(user=user)
            # For now, assume email notifications are enabled
            # You could add more granular email preferences here
        except NotificationPreference.DoesNotExist:
            pass

        send_mail(
            subject,
            message,
            getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@yourapp.com'),
            [user.email],
            html_message=html_message,
            fail_silently=False,
        )

        logger.info(f"Sent email notification to user {user_id}")

    except Exception as e:
        logger.error(f"Error sending email notification to user {user_id}: {e}")


@shared_task
def send_bulk_notifications(user_ids, title, message, data=None, notification_type='system'):
    """
    Send push notifications to multiple users
    """
    for user_id in user_ids:
        send_push_notification.delay(user_id, title, message, data, notification_type)


@shared_task
def cleanup_expired_notifications():
    """
    Clean up old read notifications (keep last 30 days)
    """
    from django.utils import timezone
    from datetime import timedelta

    cutoff_date = timezone.now() - timedelta(days=30)
    deleted_count = Notification.objects.filter(
        is_read=True,
        created_at__lt=cutoff_date
    ).delete()

    logger.info(f"Cleaned up {deleted_count} expired notifications")


@shared_task
def update_notification_analytics():
    """
    Update daily notification analytics
    """
    from django.utils import timezone
    from django.db.models import Count, Q

    today = timezone.now().date()

    # Calculate metrics
    notifications_sent = Notification.objects.filter(
        created_at__date=today
    ).count()

    notifications_delivered = Notification.objects.filter(
        created_at__date=today,
        sent_via_push=True
    ).count()

    notifications_read = Notification.objects.filter(
        created_at__date=today,
        is_read=True
    ).count()

    active_tokens = PushToken.objects.filter(
        is_active=True,
        created_at__date=today
    ).count()

    # By type analytics
    by_type = {}
    type_counts = Notification.objects.filter(
        created_at__date=today
    ).values('notification_type').annotate(count=Count('id'))

    for item in type_counts:
        by_type[item['notification_type']] = item['count']

    # Update or create analytics record
    from .models import NotificationAnalytics
    NotificationAnalytics.objects.update_or_create(
        date=today,
        defaults={
            'notifications_sent': notifications_sent,
            'notifications_delivered': notifications_delivered,
            'notifications_read': notifications_read,
            'push_tokens_active': active_tokens,
            'by_type': by_type,
        }
    )

    logger.info(f"Updated notification analytics for {today}")
