from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db import models
from .models import Post
from apps.users.models import UserProfile
from apps.gamification.tasks import award_points

@receiver(post_save, sender=Post)
def handle_post_created(sender, instance, created, **kwargs):
    """Handle post creation - update counts and award points"""
    if created:
        # Update user posts count
        UserProfile.objects.filter(user=instance.user).update(
            posts_count=models.F('posts_count') + 1
        )
        # Award points for uploading
        award_points.delay(
            user_id=str(instance.user.id),
            action_type='upload_post',
            points=50
        )
