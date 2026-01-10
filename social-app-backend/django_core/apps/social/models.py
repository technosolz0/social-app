
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
import uuid
from apps.users.models import CustomUser
from apps.content.models import Post

class Follow(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    follower = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='following')
    following = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='followers')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'follows'
        unique_together = ('follower', 'following')
        indexes = [
            models.Index(fields=['follower', '-created_at']),
            models.Index(fields=['following', '-created_at']),
        ]

class Like(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)

    # Generic relation to support liking both posts and comments
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.UUIDField()
    content_object = GenericForeignKey('content_type', 'object_id')

    # Keep post field for backward compatibility and performance
    post = models.ForeignKey(Post, on_delete=models.CASCADE, null=True, blank=True, related_name='likes')

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'likes'
        # Unique constraint per user per content object
        unique_together = ('user', 'content_type', 'object_id')
        indexes = [
            models.Index(fields=['content_type', 'object_id', '-created_at']),
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['post', '-created_at']),
        ]

    def save(self, *args, **kwargs):
        # Set content_type and object_id from content_object if not set
        if self.content_object and not self.content_type:
            self.content_type = ContentType.objects.get_for_model(self.content_object)
            self.object_id = self.content_object.id

        # Set post field for backward compatibility if liking a post
        if hasattr(self.content_object, 'post_type'):  # It's a Post
            self.post = self.content_object

        super().save(*args, **kwargs)

class Comment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    parent = models.ForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='replies')
    text = models.TextField(max_length=500)
    likes_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'comments'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['post', '-created_at']),
            models.Index(fields=['user', '-created_at']),
        ]
