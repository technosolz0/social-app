from rest_framework import serializers
from .models import UserPoints, UserLevel, Badge, UserBadge, DailyQuest, UserQuest

class UserPointsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPoints
        fields = ['total_points', 'current_streak', 'longest_streak',
                  'last_login_date']

class UserLevelSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserLevel
        fields = ['current_level', 'tier', 'experience']

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = ['id', 'name', 'description', 'badge_type', 'icon_url',
                  'rarity', 'created_at']

class UserBadgeSerializer(serializers.ModelSerializer):
    badge = BadgeSerializer(read_only=True)

    class Meta:
        model = UserBadge
        fields = ['id', 'badge', 'earned_at']

class DailyQuestSerializer(serializers.ModelSerializer):
    user_progress = serializers.SerializerMethodField()

    class Meta:
        model = DailyQuest
        fields = ['id', 'title', 'description', 'quest_type', 'target_value',
                  'points_reward', 'start_date', 'end_date', 'user_progress']

    def get_user_progress(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                user_quest = UserQuest.objects.get(user=request.user, quest=obj)
                return {
                    'progress': user_quest.progress,
                    'is_completed': user_quest.is_completed,
                }
            except UserQuest.DoesNotExist:
                return {'progress': 0, 'is_completed': False}
        return None
