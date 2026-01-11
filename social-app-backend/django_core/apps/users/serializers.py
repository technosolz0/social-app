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
    # Flatten profile fields with proper null handling
    bio = serializers.SerializerMethodField()
    avatar = serializers.SerializerMethodField()
    website = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    followers_count = serializers.SerializerMethodField()
    following_count = serializers.SerializerMethodField()
    posts_count = serializers.SerializerMethodField()
    is_private = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'bio', 'avatar', 'website', 'location',
                  'followers_count', 'following_count', 'posts_count', 'is_private',
                  'is_verified', 'is_creator', 'created_at']
        read_only_fields = ['id', 'created_at', 'is_verified', 'followers_count',
                           'following_count', 'posts_count']

    def get_bio(self, obj):
        return getattr(obj.profile, 'bio', None) if hasattr(obj, 'profile') else None

    def get_avatar(self, obj):
        return getattr(obj.profile, 'avatar', None) if hasattr(obj, 'profile') else None

    def get_website(self, obj):
        return getattr(obj.profile, 'website', None) if hasattr(obj, 'profile') else None

    def get_location(self, obj):
        return getattr(obj.profile, 'location', None) if hasattr(obj, 'profile') else None

    def get_followers_count(self, obj):
        return getattr(obj.profile, 'followers_count', 0) if hasattr(obj, 'profile') else 0

    def get_following_count(self, obj):
        return getattr(obj.profile, 'following_count', 0) if hasattr(obj, 'profile') else 0

    def get_posts_count(self, obj):
        return getattr(obj.profile, 'posts_count', 0) if hasattr(obj, 'profile') else 0

    def get_is_private(self, obj):
        return getattr(obj.profile, 'is_private', False) if hasattr(obj, 'profile') else False

class UserDetailSerializer(serializers.ModelSerializer):
    # Flatten profile fields with proper null handling
    bio = serializers.SerializerMethodField()
    avatar = serializers.SerializerMethodField()
    website = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    followers_count = serializers.SerializerMethodField()
    following_count = serializers.SerializerMethodField()
    posts_count = serializers.SerializerMethodField()
    is_private = serializers.SerializerMethodField()

    points = serializers.SerializerMethodField()
    level = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'bio', 'avatar', 'website', 'location',
                  'followers_count', 'following_count', 'posts_count', 'is_private',
                  'is_verified', 'is_creator', 'points', 'level', 'created_at']

    def get_bio(self, obj):
        return getattr(obj.profile, 'bio', None) if hasattr(obj, 'profile') else None

    def get_avatar(self, obj):
        return getattr(obj.profile, 'avatar', None) if hasattr(obj, 'profile') else None

    def get_website(self, obj):
        return getattr(obj.profile, 'website', None) if hasattr(obj, 'profile') else None

    def get_location(self, obj):
        return getattr(obj.profile, 'location', None) if hasattr(obj, 'profile') else None

    def get_followers_count(self, obj):
        return getattr(obj.profile, 'followers_count', 0) if hasattr(obj, 'profile') else 0

    def get_following_count(self, obj):
        return getattr(obj.profile, 'following_count', 0) if hasattr(obj, 'profile') else 0

    def get_posts_count(self, obj):
        return getattr(obj.profile, 'posts_count', 0) if hasattr(obj, 'profile') else 0

    def get_is_private(self, obj):
        return getattr(obj.profile, 'is_private', False) if hasattr(obj, 'profile') else False

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
