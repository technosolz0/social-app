from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _


class Notification(models.Model):
    """
    User notifications (likes, comments, follows, etc.).
    """
    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )

    NOTIFICATION_TYPES = [
        ('like', 'Like'),
        ('comment', 'Comment'),
        ('follow', 'Follow'),
        ('mention', 'Mention'),
        ('share', 'Share'),
        ('gift', 'Gift'),
        ('badge', 'Badge Earned'),
        ('level_up', 'Level Up'),
        ('system', 'System'),
        ('marketing', 'Marketing'),
    ]
    notification_type = models.CharField(
        max_length=15,
        choices=NOTIFICATION_TYPES
    )

    # Content
    title = models.CharField(max_length=200)
    message = models.TextField(max_length=1000)
    data = models.JSONField(default=dict, blank=True)  # Additional data for deep linking

    # Related objects
    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications_sent'
    )
    post = models.ForeignKey(
        'content.Post',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications'
    )
    story = models.ForeignKey(
        'content.Story',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications'
    )
    comment = models.ForeignKey(
        'social.Comment',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications'
    )

    # Status
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)

    # Delivery methods
    sent_via_email = models.BooleanField(default=False)
    sent_via_push = models.BooleanField(default=False)
    sent_via_in_app = models.BooleanField(default=True)

    # Grouping (for batching similar notifications)
    group_key = models.CharField(max_length=100, blank=True)
    is_grouped = models.BooleanField(default=False)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    scheduled_at = models.DateTimeField(null=True, blank=True)  # For scheduled notifications

    class Meta:
        verbose_name = _('notification')
        verbose_name_plural = _('notifications')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', '-created_at']),
            models.Index(fields=['recipient', 'is_read']),
            models.Index(fields=['notification_type']),
        ]

    def __str__(self):
        return f"Notification to {self.recipient.username}: {self.title}"

    def mark_as_read(self):
        """Mark notification as read."""
        from django.utils import timezone
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save()


class PushToken(models.Model):
    """
    Device push notification tokens.
    """
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='push_tokens'
    )

    token = models.TextField(unique=True)
    device_type = models.CharField(
        max_length=20,
        choices=[
            ('ios', 'iOS'),
            ('android', 'Android'),
            ('web', 'Web'),
        ]
    )
    device_id = models.CharField(max_length=100, blank=True)

    # Status
    is_active = models.BooleanField(default=True)
    last_used = models.DateTimeField(auto_now=True)

    # App version info
    app_version = models.CharField(max_length=20, blank=True)
    os_version = models.CharField(max_length=20, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _('push token')
        verbose_name_plural = _('push tokens')
        unique_together = ['user', 'device_id']

    def __str__(self):
        return f"{self.user.username}'s {self.device_type} device"


class NotificationPreference(models.Model):
    """
    User notification preferences.
    """
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notification_preferences'
    )

    # Email notifications
    email_likes = models.BooleanField(default=True)
    email_comments = models.BooleanField(default=True)
    email_follows = models.BooleanField(default=True)
    email_mentions = models.BooleanField(default=True)
    email_gifts = models.BooleanField(default=True)
    email_badges = models.BooleanField(default=True)
    email_marketing = models.BooleanField(default=False)
    email_weekly_digest = models.BooleanField(default=True)

    # Push notifications
    push_likes = models.BooleanField(default=True)
    push_comments = models.BooleanField(default=True)
    push_follows = models.BooleanField(default=True)
    push_mentions = models.BooleanField(default=True)
    push_gifts = models.BooleanField(default=True)
    push_badges = models.BooleanField(default=True)
    push_system = models.BooleanField(default=True)

    # In-app notifications
    in_app_likes = models.BooleanField(default=True)
    in_app_comments = models.BooleanField(default=True)
    in_app_follows = models.BooleanField(default=True)
    in_app_mentions = models.BooleanField(default=True)
    in_app_gifts = models.BooleanField(default=True)
    in_app_badges = models.BooleanField(default=True)

    # Quiet hours
    quiet_hours_enabled = models.BooleanField(default=False)
    quiet_hours_start = models.TimeField(null=True, blank=True)
    quiet_hours_end = models.TimeField(null=True, blank=True)

    # Frequency settings
    digest_frequency = models.CharField(
        max_length=10,
        choices=[
            ('daily', 'Daily'),
            ('weekly', 'Weekly'),
            ('monthly', 'Monthly'),
            ('never', 'Never'),
        ],
        default='weekly'
    )

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('notification preference')
        verbose_name_plural = _('notification preferences')

    def __str__(self):
        return f"{self.user.username}'s notification preferences"


class NotificationTemplate(models.Model):
    """
    Reusable notification templates.
    """
    name = models.CharField(max_length=100, unique=True)
    notification_type = models.CharField(
        max_length=15,
        choices=Notification.NOTIFICATION_TYPES
    )

    # Template content
    title_template = models.CharField(max_length=200)  # e.g., "{actor} liked your post"
    message_template = models.TextField(max_length=1000)

    # Variables available in template
    available_variables = models.JSONField(default=list, blank=True)

    # Delivery preferences
    send_email = models.BooleanField(default=False)
    send_push = models.BooleanField(default=True)
    send_in_app = models.BooleanField(default=True)

    # Targeting
    target_audience = models.CharField(
        max_length=20,
        choices=[
            ('all', 'All Users'),
            ('premium', 'Premium Users'),
            ('active', 'Active Users'),
            ('inactive', 'Inactive Users'),
        ],
        default='all'
    )

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('notification template')
        verbose_name_plural = _('notification templates')

    def __str__(self):
        return f"{self.name} ({self.notification_type})"


class EmailCampaign(models.Model):
    """
    Email marketing campaigns.
    """
    name = models.CharField(max_length=200)
    subject = models.CharField(max_length=200)
    content = models.TextField()

    # Targeting
    target_users = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='email_campaigns',
        blank=True
    )
    target_segments = models.JSONField(default=dict, blank=True)  # User segment criteria

    # Scheduling
    scheduled_at = models.DateTimeField(null=True, blank=True)
    sent_at = models.DateTimeField(null=True, blank=True)

    # Status
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('scheduled', 'Scheduled'),
        ('sending', 'Sending'),
        ('sent', 'Sent'),
        ('cancelled', 'Cancelled'),
    ]
    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default='draft'
    )

    # Analytics
    total_recipients = models.PositiveIntegerField(default=0)
    sent_count = models.PositiveIntegerField(default=0)
    open_count = models.PositiveIntegerField(default=0)
    click_count = models.PositiveIntegerField(default=0)
    unsubscribe_count = models.PositiveIntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('email campaign')
        verbose_name_plural = _('email campaigns')
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    @property
    def open_rate(self):
        return (self.open_count / self.sent_count * 100) if self.sent_count > 0 else 0

    @property
    def click_rate(self):
        return (self.click_count / self.sent_count * 100) if self.sent_count > 0 else 0


class NotificationAnalytics(models.Model):
    """
    Analytics for notification delivery and engagement.
    """
    date = models.DateField()

    # Delivery metrics
    notifications_sent = models.PositiveIntegerField(default=0)
    notifications_delivered = models.PositiveIntegerField(default=0)
    push_tokens_active = models.PositiveIntegerField(default=0)

    # Engagement metrics
    notifications_read = models.PositiveIntegerField(default=0)
    notifications_clicked = models.PositiveIntegerField(default=0)

    # By type
    by_type = models.JSONField(default=dict, blank=True)

    # By platform
    by_platform = models.JSONField(default=dict, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _('notification analytics')
        verbose_name_plural = _('notification analytics')
        unique_together = ['date']
        ordering = ['-date']

    def __str__(self):
        return f"Notification analytics for {self.date}"
