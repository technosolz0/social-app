from django.db import models
import uuid

from apps.users.models import CustomUser

class Activity(models.Model):
    ACTIVITY_TYPES = [
        ('post_view', 'Post View'),
        ('post_like', 'Post Like'),
        ('story_view', 'Story View'),
        ('profile_view', 'Profile View'),
        ('search', 'Search'),
        ('message_sent', 'Message Sent'),
        ('login', 'Login'),
        ('video_watch', 'Video Watch'),
        ('follow', 'Follow'),
        ('comment', 'Comment'),
        ('share', 'Share'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='activities')
    activity_type = models.CharField(max_length=20, choices=ACTIVITY_TYPES)
    metadata = models.JSONField(default=dict, blank=True, help_text="Additional data for the activity")
    timestamp = models.DateTimeField(auto_now_add=True)

    # Optional references to related objects
    post_id = models.UUIDField(null=True, blank=True)
    story_id = models.UUIDField(null=True, blank=True)
    target_user_id = models.UUIDField(null=True, blank=True)  # For profile views, follows, etc.

    class Meta:
        db_table = 'activities'
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['user', '-timestamp']),
            models.Index(fields=['activity_type', '-timestamp']),
            models.Index(fields=['post_id']),
            models.Index(fields=['target_user_id']),
        ]

    def __str__(self):
        return f"{self.user.username} - {self.activity_type} - {self.timestamp}"
