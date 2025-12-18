from rest_framework import serializers
from .models import CustomUser, UserProfile
from apps.gamification.models import UserPoints, UserLevel

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['bio', 'avatar', 'cover_photo', 'website', 'location',
                  'date_of_birth', 'gender', 'followers_count', 'following_count',
                  'posts_count', 'is_private', 'allow_messages']
        read_only_fields = ['followers_count', 'following_count', 'posts_count']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'is_verified', 'is_creator',
                  'profile', 'created_at']
        read_only_fields = ['id', 'created_at', 'is_verified']

class UserDetailSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer()
    points = serializers.SerializerMethodField()
    level = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'is_verified', 'is_creator',
                  'profile', 'points', 'level', 'created_at']

    def get_points(self, obj):
        try:
            return {
                'total': obj.points.total_points,
                'streak': obj.points.current_streak,
            }
        except:
            return {'total': 0, 'streak': 0}

    def get_level(self, obj):
        try:
            return {
                'level': obj.level.current_level,
                'tier': obj.level.tier,
                'experience': obj.level.experience,
            }
        except:
            return {'level': 1, 'tier': 'beginner', 'experience': 0}

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password']

    def create(self, validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        return user
