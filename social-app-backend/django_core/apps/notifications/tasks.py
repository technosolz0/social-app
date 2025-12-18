from celery import shared_task
import logging

logger = logging.getLogger(__name__)

@shared_task
def send_push_notification(user_id, title, message, data=None):
    """Send push notification to user"""
    # TODO: Implement with FCM or similar
    pass

@shared_task
def send_email_notification(user_id, subject, message):
    """Send email notification"""
    from django.core.mail import send_mail
    from django_core.apps.users.models import CustomUser

    try:
        user = CustomUser.objects.get(id=user_id)
        send_mail(
            subject,
            message,
            'noreply@yourapp.com',
            [user.email],
            fail_silently=False,
        )
    except Exception as e:
        logger.error(f"Error sending email: {e}")
