from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.db import models
from .models import Like, Comment, Follow
from django_core.apps.content.models import Post
from django_core.apps.gamification.tasks import award_points

@receiver(post_save, sender=Like)
def handle_like_created(sender, instance, created, **kwargs):
    """Handle like creation - update counts and award points"""
    if created:
        # Update post likes count
        Post.objects.filter(id=instance.post.id).update(
            likes_count=models.F('likes_count') + 1
        )
        # Award points to post owner
        award_points.delay(
            user_id=str(instance.post.user.id),
            action_type='get_like',
            points=1
        )

@receiver(post_delete, sender=Like)
def handle_like_deleted(sender, instance, **kwargs):
    """Decrement like count when like is removed"""
    Post.objects.filter(id=instance.post.id).update(
        likes_count=models.F('likes_count') - 1
    )

@receiver(post_save, sender=Comment)
def handle_comment_created(sender, instance, created, **kwargs):
    """Handle comment creation"""
    if created:
        # Update post comments count
        Post.objects.filter(id=instance.post.id).update(
            comments_count=models.F('comments_count') + 1
        )
        # Award points to post owner
        award_points.delay(
            user_id=str(instance.post.user.id),
            action_type='get_comment',
            points=5
        )

@receiver(post_save, sender=Follow)
def handle_follow_created(sender, instance, created, **kwargs):
    """Update follower/following counts"""
    if created:
        from django_core.apps.users.models import UserProfile
        # Update follower count
        UserProfile.objects.filter(user=instance.following).update(
            followers_count=models.F('followers_count') + 1
        )
        # Update following count
        UserProfile.objects.filter(user=instance.follower).update(
            following_count=models.F('following_count') + 1
        )

@receiver(post_delete, sender=Follow)
def handle_follow_deleted(sender, instance, **kwargs):
    """Decrement counts when unfollow"""
    from django_core.apps.users.models import UserProfile
    UserProfile.objects.filter(user=instance.following).update(
        followers_count=models.F('followers_count') - 1
    )
    UserProfile.objects.filter(user=instance.follower).update(
        following_count=models.F('following_count') - 1
    )
