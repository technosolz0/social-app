from django.contrib import admin
from .models import (UserPoints, PointsTransaction, UserLevel,
                     Badge, UserBadge, DailyQuest, UserQuest)

@admin.register(UserPoints)
class UserPointsAdmin(admin.ModelAdmin):
    list_display = ['user', 'total_points', 'current_streak', 'longest_streak']
    search_fields = ['user__username']
    raw_id_fields = ['user']
    ordering = ['-total_points']

@admin.register(PointsTransaction)
class PointsTransactionAdmin(admin.ModelAdmin):
    list_display = ['user', 'action_type', 'points', 'created_at']
    list_filter = ['action_type', 'created_at']
    search_fields = ['user__username']
    raw_id_fields = ['user']
    date_hierarchy = 'created_at'

@admin.register(UserLevel)
class UserLevelAdmin(admin.ModelAdmin):
    list_display = ['user', 'current_level', 'tier', 'experience']
    list_filter = ['tier']
    search_fields = ['user__username']
    raw_id_fields = ['user']
    ordering = ['-current_level']

@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ['name', 'badge_type', 'rarity', 'is_active']
    list_filter = ['badge_type', 'rarity', 'is_active']
    search_fields = ['name', 'description']

@admin.register(UserBadge)
class UserBadgeAdmin(admin.ModelAdmin):
    list_display = ['user', 'badge', 'earned_at']
    list_filter = ['badge', 'earned_at']
    search_fields = ['user__username', 'badge__name']
    raw_id_fields = ['user', 'badge']
    date_hierarchy = 'earned_at'

@admin.register(DailyQuest)
class DailyQuestAdmin(admin.ModelAdmin):
    list_display = ['title', 'quest_type', 'target_value', 'points_reward',
                    'is_active', 'start_date', 'end_date']
    list_filter = ['is_active', 'quest_type', 'start_date']
    search_fields = ['title', 'description']

@admin.register(UserQuest)
class UserQuestAdmin(admin.ModelAdmin):
    list_display = ['user', 'quest', 'progress', 'is_completed', 'completed_at']
    list_filter = ['is_completed', 'created_at']
    search_fields = ['user__username', 'quest__title']
    raw_id_fields = ['user', 'quest']
