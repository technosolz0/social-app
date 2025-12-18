from rest_framework import serializers
from .models import Follow, Like, Comment
from apps.users.serializers import UserSerializer

class FollowSerializer(serializers.ModelSerializer):
    follower = UserSerializer(read_only=True)
    following = UserSerializer(read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'follower', 'following', 'created_at']

class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    replies_count = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = ['id', 'user', 'post', 'parent', 'text', 'likes_count',
                  'replies_count', 'created_at', 'updated_at']
        read_only_fields = ['likes_count', 'created_at', 'updated_at']

    def get_replies_count(self, obj):
        return obj.replies.count()
