from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
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

    @extend_schema_field(serializers.DictField)
    def get_points(self, obj):
        try:
            return {
                'total': obj.points.total_points,
                'streak': obj.points.current_streak,
            }
        except:
            return {'total': 0, 'streak': 0}

    @extend_schema_field(serializers.DictField)
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
    password = serializers.CharField(write_only=True, min_length=6)
    identifier = serializers.CharField(write_only=True)  # Can be username or email

    class Meta:
        model = CustomUser
        fields = ['identifier', 'password']

    def validate_identifier(self, value):
        # Check if it's an email or username
        if '@' in value:
            # It's an email
            if CustomUser.objects.filter(email=value).exists():
                raise serializers.ValidationError("A user with this email already exists.")
        else:
            # It's a username
            if CustomUser.objects.filter(username=value).exists():
                raise serializers.ValidationError("A user with this username already exists.")

        return value

    def create(self, validated_data):
        identifier = validated_data.pop('identifier')
        password = validated_data.pop('password')

        # Determine if identifier is email or username
        if '@' in identifier:
            # It's an email - create username from email prefix, ensure uniqueness
            base_username = identifier.split('@')[0]
            username = base_username
            counter = 1

            # Ensure username is unique
            while CustomUser.objects.filter(username=username).exists():
                username = f"{base_username}{counter}"
                counter += 1

            user = CustomUser.objects.create_user(
                email=identifier,
                password=password,
                username=username
            )
        else:
            # It's a username - ensure it's unique
            if CustomUser.objects.filter(username=identifier).exists():
                raise serializers.ValidationError("A user with this username already exists.")

            user = CustomUser.objects.create_user(
                username=identifier,
                password=password
            )

        # Create user profile
        UserProfile.objects.get_or_create(user=user)

        return user
