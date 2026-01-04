from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import CustomUser, UserProfile
from apps.gamification.models import UserPoints, UserLevel
from apps.monetization.models import UserWallet

@receiver(post_save, sender=CustomUser)
def create_user_related_models(sender, instance, created, **kwargs):
    """Create related models when user is created"""
    if created:
        UserProfile.objects.create(user=instance)
        UserPoints.objects.create(user=instance)
        UserLevel.objects.create(user=instance)
        UserWallet.objects.create(user=instance)
