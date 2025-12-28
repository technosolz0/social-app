from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import Post, Story
from apps.users.serializers import UserSerializer

class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ['id', 'user', 'post_type', 'caption', 'media_url',
                  'thumbnail_url', 'duration', 'likes_count', 'comments_count',
                  'shares_count', 'views_count', 'hashtags', 'mentions',
                  'location', 'music_id', 'is_liked', 'created_at']
        read_only_fields = ['id', 'likes_count', 'comments_count',
                           'shares_count', 'views_count', 'created_at']

    @extend_schema_field(serializers.BooleanField)
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            from apps.social.models import Like
            return Like.objects.filter(user=request.user, post=obj).exists()
        return False

class PostCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ['post_type', 'caption', 'media_url', 'thumbnail_url',
                  'duration', 'hashtags', 'mentions', 'location', 'music_id']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class StorySerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Story
        fields = ['id', 'user', 'media_url', 'media_type', 'duration',
                  'views_count', 'expires_at', 'created_at']
