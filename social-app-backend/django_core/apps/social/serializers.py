from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import Follow, Like, Comment, Report
from apps.users.serializers import UserSerializer

class FollowSerializer(serializers.ModelSerializer):
    follower = UserSerializer(read_only=True)
    following = UserSerializer(read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'follower', 'following', 'created_at']

class LikeSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Like
        fields = ['id', 'user', 'post', 'created_at']

class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    replies_count = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = ['id', 'user', 'post', 'parent', 'text', 'likes_count',
                  'replies_count', 'is_liked', 'created_at', 'updated_at']
        read_only_fields = ['likes_count', 'created_at', 'updated_at']

    @extend_schema_field(serializers.IntegerField)
    def get_replies_count(self, obj):
        return obj.replies.count()
    
    @extend_schema_field(serializers.BooleanField)
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            from django.contrib.contenttypes.models import ContentType
            return Like.objects.filter(
                user=request.user,
                content_type=ContentType.objects.get_for_model(Comment),
                object_id=obj.id
            ).exists()
        return False

class ReportSerializer(serializers.ModelSerializer):
    reporter = UserSerializer(read_only=True)
    content_type_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Report
        fields = ['id', 'reporter', 'content_type', 'object_id', 'content_type_name',
                  'category', 'description', 'status', 'created_at', 'updated_at']
        read_only_fields = ['reporter', 'status', 'created_at', 'updated_at']
    
    @extend_schema_field(serializers.CharField)
    def get_content_type_name(self, obj):
        return obj.content_type.model
    
    def validate(self, data):
        """Validate that the content object exists"""
        from django.contrib.contenttypes.models import ContentType
        
        content_type = data.get('content_type')
        object_id = data.get('object_id')
        
        if content_type and object_id:
            model_class = content_type.model_class()
            if not model_class.objects.filter(id=object_id).exists():
                raise serializers.ValidationError(
                    f"The {content_type.model} with id {object_id} does not exist."
                )
        
        return data

class ReportCreateSerializer(serializers.ModelSerializer):
    """Simplified serializer for creating reports"""
    
    class Meta:
        model = Report
        fields = ['content_type', 'object_id', 'category', 'description']
    
    def validate(self, data):
        """Validate that the content object exists"""
        from django.contrib.contenttypes.models import ContentType
        
        content_type = data.get('content_type')
        object_id = data.get('object_id')
        
        if content_type and object_id:
            model_class = content_type.model_class()
            if not model_class.objects.filter(id=object_id).exists():
                raise serializers.ValidationError(
                    f"The {content_type.model} with id {object_id} does not exist."
                )
        
        return data
