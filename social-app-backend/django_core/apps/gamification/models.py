

import uuid
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

from apps.users.models import CustomUser

class UserPoints(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='points')
    total_points = models.IntegerField(default=0)
    current_streak = models.IntegerField(default=0)
    longest_streak = models.IntegerField(default=0)
    last_login_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_points'

class PointsTransaction(models.Model):
    ACTION_TYPES = [
        ('upload_post', 'Upload Post'),
        ('get_like', 'Received Like'),
        ('get_comment', 'Received Comment'),
        ('comment_post', 'Comment on Post'),
        ('reply_comment', 'Reply to Comment'),
        ('follow_user', 'Follow User'),
        ('daily_login', 'Daily Login'),
        ('use_filter', 'Use Filter'),
        ('invite_friend', 'Invite Friend'),
        ('complete_quest', 'Complete Quest'),
        ('streak_bonus', 'Streak Bonus'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='point_transactions')
    action_type = models.CharField(max_length=50, choices=ACTION_TYPES)
    points = models.IntegerField()
    description = models.TextField(blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'points_transactions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
        ]

class UserLevel(models.Model):
    LEVEL_TIERS = [
        ('beginner', 'Beginner'),
        ('creator', 'Creator'),
        ('super_creator', 'Super Creator'),
        ('influencer', 'Influencer Prime'),
    ]
    
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='level')
    current_level = models.IntegerField(default=1, validators=[MinValueValidator(1)])
    tier = models.CharField(max_length=20, choices=LEVEL_TIERS, default='beginner')
    experience = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_levels'

class Badge(models.Model):
    BADGE_TYPES = [
        ('activity', 'Activity'),
        ('content', 'Content'),
        ('social', 'Social'),
        ('special', 'Special'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    description = models.TextField()
    badge_type = models.CharField(max_length=20, choices=BADGE_TYPES)
    icon_url = models.URLField()
    criteria = models.JSONField(help_text="Criteria to earn this badge")
    rarity = models.CharField(max_length=20, choices=[
        ('common', 'Common'),
        ('rare', 'Rare'),
        ('epic', 'Epic'),
        ('legendary', 'Legendary'),
    ], default='common')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'badges'

class UserBadge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='badges')
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    earned_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'user_badges'
        unique_together = ('user', 'badge')

class DailyQuest(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200)
    description = models.TextField()
    quest_type = models.CharField(max_length=50)
    target_value = models.IntegerField()
    points_reward = models.IntegerField()
    is_active = models.BooleanField(default=True)
    start_date = models.DateField()
    end_date = models.DateField()
    
    class Meta:
        db_table = 'daily_quests'

class UserQuest(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    quest = models.ForeignKey(DailyQuest, on_delete=models.CASCADE)
    progress = models.IntegerField(default=0)
    is_completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'user_quests'
        unique_together = ('user', 'quest')

class GamificationConfig(models.Model):
    """Configuration for gamification points"""
    key = models.CharField(max_length=50, unique=True, help_text="Action key, e.g. upload_post")
    points = models.IntegerField(default=0, help_text="Points awarded for this action")
    description = models.CharField(max_length=200, blank=True)
    is_active = models.BooleanField(default=True)
    
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'gamification_config'
        verbose_name = 'Gamification Configuration'
        verbose_name_plural = 'Gamification Configurations'
    
    def __str__(self):
        return f"{self.key}: {self.points} pts"
