from apps.notifications.tasks import send_push_notification
from typing import Dict

class NotificationService:
    """
    Service for sending notifications
    """

    @staticmethod
    def send_notification(
        user_id: str,
        notification_type: str,
        title: str,
        message: str,
        data: Dict = None
    ):
        """
        Send notification to user
        """
        # Send push notification async
        send_push_notification.delay(
            user_id=user_id,
            title=title,
            message=message,
            data=data or {}
        )

    @staticmethod
    def notify_new_follower(follower_id: str, following_id: str):
        """
        Notify user about new follower
        """
        from apps.users.models import CustomUser

        try:
            follower = CustomUser.objects.get(id=follower_id)
            NotificationService.send_notification(
                user_id=following_id,
                notification_type='new_follower',
                title='New Follower',
                message=f'{follower.username} started following you',
                data={'follower_id': follower_id}
            )
        except:
            pass

    @staticmethod
    def notify_new_like(liker_id: str, post_owner_id: str, post_id: str):
        """
        Notify post owner about new like
        """
        from apps.users.models import CustomUser

        try:
            liker = CustomUser.objects.get(id=liker_id)
            NotificationService.send_notification(
                user_id=post_owner_id,
                notification_type='new_like',
                title='New Like',
                message=f'{liker.username} liked your post',
                data={'post_id': post_id, 'liker_id': liker_id}
            )
        except:
            pass

    @staticmethod
    def notify_new_comment(commenter_id: str, post_owner_id: str, post_id: str, comment_text: str):
        """
        Notify post owner about new comment
        """
        from apps.users.models import CustomUser

        try:
            commenter = CustomUser.objects.get(id=commenter_id)
            NotificationService.send_notification(
                user_id=post_owner_id,
                notification_type='new_comment',
                title='New Comment',
                message=f'{commenter.username} commented: {comment_text[:50]}',
                data={'post_id': post_id, 'commenter_id': commenter_id}
            )
        except:
            pass
