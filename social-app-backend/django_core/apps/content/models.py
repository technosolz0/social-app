from django.db import models
import uuid

from apps.users.models import CustomUser

class Post(models.Model):
    POST_TYPES = [
        ('photo', 'Photo'),
        ('video', 'Video'),
        ('reel', 'Reel'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='posts')
    post_type = models.CharField(max_length=10, choices=POST_TYPES)
    caption = models.TextField(max_length=2200, blank=True)
    media_url = models.URLField()
    thumbnail_url = models.URLField(blank=True)
    duration = models.IntegerField(null=True, blank=True, help_text="Duration in seconds for videos")
    
    # Engagement metrics (denormalized)
    likes_count = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    shares_count = models.IntegerField(default=0)
    views_count = models.IntegerField(default=0)
    
    # Content metadata
    hashtags = models.JSONField(default=list, blank=True)
    mentions = models.JSONField(default=list, blank=True)
    location = models.JSONField(null=True, blank=True)
    music_id = models.CharField(max_length=100, blank=True)
    
    # AI features
    ai_caption = models.TextField(blank=True)
    ai_tags = models.JSONField(default=list, blank=True)
    
    # Moderation
    is_approved = models.BooleanField(default=True)
    is_flagged = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'posts'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['post_type', '-created_at']),
            models.Index(fields=['-likes_count']),
        ]

class Story(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='stories')
    media_url = models.URLField()
    media_type = models.CharField(max_length=10, choices=[('photo', 'Photo'), ('video', 'Video')])
    duration = models.IntegerField(default=15)
    views_count = models.IntegerField(default=0)
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'stories'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['expires_at']),
        ]
