from rest_framework import serializers
from .models import Activity

class ActivitySerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    user_avatar = serializers.URLField(source='user.profile.avatar', read_only=True)

    class Meta:
        model = Activity
        fields = [
            'id', 'activity_type', 'metadata', 'timestamp',
            'post_id', 'story_id', 'target_user_id',
            'username', 'user_avatar'
        ]
        read_only_fields = ['id', 'timestamp', 'username', 'user_avatar']

class ActivityCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Activity
        fields = ['activity_type', 'metadata', 'post_id', 'story_id', 'target_user_id']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
