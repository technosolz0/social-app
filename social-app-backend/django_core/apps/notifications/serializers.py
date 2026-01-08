from rest_framework import serializers
from .models import Notification, PushToken, NotificationPreference


class NotificationSerializer(serializers.ModelSerializer):
    actor_username = serializers.CharField(source='actor.username', read_only=True)
    actor_avatar = serializers.CharField(source='actor.profile.avatar', read_only=True)

    class Meta:
        model = Notification
        fields = [
            'id', 'notification_type', 'title', 'message', 'data',
            'is_read', 'read_at', 'created_at', 'actor_username', 'actor_avatar'
        ]
        read_only_fields = ['id', 'created_at', 'read_at']


class PushTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = PushToken
        fields = [
            'id', 'token', 'device_type', 'device_id',
            'is_active', 'app_version', 'os_version',
            'last_used', 'created_at'
        ]
        read_only_fields = ['id', 'last_used', 'created_at']
        extra_kwargs = {
            'token': {'write_only': True}  # Don't expose tokens in responses
        }


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = [
            'email_likes', 'email_comments', 'email_follows', 'email_mentions',
            'email_gifts', 'email_badges', 'email_marketing', 'email_weekly_digest',
            'push_likes', 'push_comments', 'push_follows', 'push_mentions',
            'push_gifts', 'push_badges', 'push_system',
            'in_app_likes', 'in_app_comments', 'in_app_follows', 'in_app_mentions',
            'in_app_gifts', 'in_app_badges',
            'quiet_hours_enabled', 'quiet_hours_start', 'quiet_hours_end',
            'digest_frequency', 'updated_at'
        ]