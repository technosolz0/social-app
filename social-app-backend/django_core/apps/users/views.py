from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate
from django.contrib.auth.tokens import default_token_generator
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.authentication import JWTAuthentication
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample
from .models import CustomUser, UserProfile
from .serializers import (UserSerializer, UserDetailSerializer,
                          UserRegistrationSerializer, UserProfileSerializer)

class UserViewSet(viewsets.ModelViewSet):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    authentication_classes = [JWTAuthentication]

    def get_permissions(self):
        if self.action in ['create', 'login']:
            return [AllowAny()]
        return [IsAuthenticated()]

    def get_serializer_class(self):
        if self.action == 'create':
            return UserRegistrationSerializer
        elif self.action == 'retrieve':
            return UserDetailSerializer
        return UserSerializer

    def create(self, request, *args, **kwargs):
        """Override create to register device token during registration"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Register device token if provided
        self._register_device_token(user, request.data)

        # Return response with tokens
        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)

    @extend_schema(
        summary="User Login",
        description="Simple login with username/email and password. Returns JWT tokens.",
        request={
            "application/json": {
                "type": "object",
                "properties": {
                    "identifier": {
                        "type": "string",
                        "description": "Username or email address",
                        "example": "alice@example.com"
                    },
                    "password": {
                        "type": "string",
                        "description": "User password",
                        "example": "testpass123"
                    }
                },
                "required": ["identifier", "password"]
            }
        },
        responses={
            200: {
                "type": "object",
                "properties": {
                    "access": {"type": "string", "description": "JWT access token"},
                    "refresh": {"type": "string", "description": "JWT refresh token"},
                    "user": {"$ref": "#/components/schemas/User"}
                }
            },
            401: {
                "type": "object",
                "properties": {
                    "error": {"type": "string", "example": "Invalid credentials"}
                }
            }
        },
        examples=[
            OpenApiExample(
                "Login with email",
                value={
                    "identifier": "alice@example.com",
                    "password": "testpass123"
                }
            ),
            OpenApiExample(
                "Login with username",
                value={
                    "identifier": "alice",
                    "password": "testpass123"
                }
            )
        ]
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        """Simple login - accepts username or email and password"""
        identifier = request.data.get('identifier')
        password = request.data.get('password')

        if not identifier or not password:
            return Response(
                {'error': 'Identifier and password are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Since USERNAME_FIELD = 'email', we need to handle authentication differently
        # First try to authenticate with identifier as email
        user = authenticate(username=identifier, password=password)

        # If that fails, try to find user by username and authenticate with their email
        if user is None:
            try:
                found_user = CustomUser.objects.get(username=identifier)
                user = authenticate(username=found_user.email, password=password)
            except CustomUser.DoesNotExist:
                pass

        if user:
            # Check if user should be auto-verified (1M followers)
            if not user.is_verified and hasattr(user, 'profile'):
                if user.profile.followers_count >= 1000000:
                    user.is_verified = True
                    user.save()

            # Register device token if provided
            self._register_device_token(user, request.data)

            refresh = RefreshToken.for_user(user)
            return Response({
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user': UserSerializer(user).data
            })

        return Response(
            {'error': 'Invalid credentials'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    @action(detail=False, methods=['get', 'patch', 'put'])
    def me(self, request):
        """Get or update current user profile"""
        if request.method == 'GET':
            serializer = UserDetailSerializer(request.user)
            return Response(serializer.data)
        elif request.method in ['PATCH', 'PUT']:
            # Handle partial updates for both user and profile
            user_data = {}
            profile_data = {}

            # Separate user fields from profile fields
            user_fields = ['username', 'email']
            for field in user_fields:
                if field in request.data:
                    user_data[field] = request.data[field]

            # Remaining fields go to profile
            for key, value in request.data.items():
                if key not in user_fields:
                    profile_data[key] = value

            # Update user if there are user fields
            if user_data:
                user_serializer = UserDetailSerializer(request.user, data=user_data, partial=True)
                if user_serializer.is_valid():
                    user_serializer.save()
                else:
                    return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

            # Update profile if there are profile fields
            if profile_data:
                profile_serializer = UserProfileSerializer(request.user.profile, data=profile_data, partial=True)
                if profile_serializer.is_valid():
                    profile_serializer.save()
                else:
                    return Response(profile_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

            # Return updated user data
            serializer = UserDetailSerializer(request.user)
            return Response(serializer.data)

    @action(detail=False, methods=['patch'])
    def update_profile(self, request):
        """Update user profile"""
        profile = request.user.profile
        serializer = UserProfileSerializer(profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def verify_user(self, request, pk=None):
        """Verify a user (admin only)"""
        if not request.user.is_staff:
            return Response(
                {'error': 'Only admins can verify users'},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            user = CustomUser.objects.get(pk=pk)
            user.is_verified = True
            user.save()

            # Track verification activity
            from apps.activities.models import Activity
            Activity.objects.create(
                user=request.user,
                activity_type='user_verified',
                target_user_id=str(user.id),
                metadata={'verified_by': str(request.user.id)}
            )

            return Response({'message': 'User verified successfully'})
        except CustomUser.DoesNotExist:
            return Response(
                {'error': 'User not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def request_verification(self, request, pk=None):
        """Request verification for current user"""
        if str(request.user.id) != pk:
            return Response(
                {'error': 'Can only request verification for yourself'},
                status=status.HTTP_403_FORBIDDEN
            )

        # Check if already verified
        if request.user.is_verified:
            return Response(
                {'error': 'User is already verified'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # TODO: Implement verification request logic
        # This could involve uploading documents, social media verification, etc.

        return Response({'message': 'Verification request submitted'})

    @extend_schema(
        summary="Request Password Reset",
        description="Send password reset email to user",
        request={
            "application/json": {
                "type": "object",
                "properties": {
                    "email": {
                        "type": "string",
                        "description": "User email address",
                        "example": "alice@example.com"
                    }
                },
                "required": ["email"]
            }
        },
        responses={
            200: {
                "type": "object",
                "properties": {
                    "message": {"type": "string", "example": "Password reset email sent"}
                }
            },
            400: {
                "type": "object",
                "properties": {
                    "error": {"type": "string", "example": "Email is required"}
                }
            }
        }
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def password_reset(self, request):
        """Request password reset - sends email with reset link"""
        email = request.data.get('email')

        if not email:
            return Response(
                {'error': 'Email is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = CustomUser.objects.get(email=email)
        except CustomUser.DoesNotExist:
            # Don't reveal if email exists or not for security
            return Response(
                {'message': 'If an account with this email exists, a password reset link has been sent.'},
                status=status.HTTP_200_OK
            )

        # Generate token
        token = default_token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))

        # Build reset URL
        reset_url = f"{settings.FRONTEND_URL}/reset-password/{uid}/{token}/"

        # Send email
        try:
            subject = 'Password Reset Request'
            message = render_to_string('password_reset_email.html', {
                'user': user,
                'reset_url': reset_url,
                'site_name': 'Social App',
            })

            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                [email],
                html_message=message,
                fail_silently=False,
            )
        except Exception as e:
            # Log error but don't fail the request
            print(f"Failed to send password reset email: {e}")

        return Response(
            {'message': 'If an account with this email exists, a password reset link has been sent.'},
            status=status.HTTP_200_OK
        )

    @extend_schema(
        summary="Confirm Password Reset",
        description="Reset password using token from email",
        request={
            "application/json": {
                "type": "object",
                "properties": {
                    "uid": {
                        "type": "string",
                        "description": "Base64 encoded user ID",
                        "example": "MQ"
                    },
                    "token": {
                        "type": "string",
                        "description": "Password reset token",
                        "example": "abc123-def456"
                    },
                    "new_password": {
                        "type": "string",
                        "description": "New password",
                        "example": "newpassword123"
                    }
                },
                "required": ["uid", "token", "new_password"]
            }
        },
        responses={
            200: {
                "type": "object",
                "properties": {
                    "message": {"type": "string", "example": "Password reset successfully"}
                }
            },
            400: {
                "type": "object",
                "properties": {
                    "error": {"type": "string", "example": "Invalid token or user"}
                }
            }
        }
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def password_reset_confirm(self, request):
        """Confirm password reset using token"""
        uid = request.data.get('uid')
        token = request.data.get('token')
        new_password = request.data.get('new_password')

        if not all([uid, token, new_password]):
            return Response(
                {'error': 'uid, token, and new_password are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Decode user ID
            user_id = force_str(urlsafe_base64_decode(uid))
            user = CustomUser.objects.get(pk=user_id)
        except (ValueError, CustomUser.DoesNotExist):
            return Response(
                {'error': 'Invalid user'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check token
        if not default_token_generator.check_token(user, token):
            return Response(
                {'error': 'Invalid or expired token'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Set new password
        user.set_password(new_password)
        user.save()

        return Response(
            {'message': 'Password reset successfully'},
            status=status.HTTP_200_OK
        )

    def _register_device_token(self, user, data):
        """Helper method to register device token during login/registration"""
        token = data.get('device_token')
        device_type = data.get('device_type', 'android')
        device_id = data.get('device_id', '')
        app_version = data.get('app_version', '')
        os_version = data.get('os_version', '')

        if token:
            try:
                from apps.notifications.models import PushToken
                # Create or update push token
                PushToken.objects.update_or_create(
                    user=user,
                    device_id=device_id or token[:50],  # Use part of token as device_id if not provided
                    defaults={
                        'token': token,
                        'device_type': device_type,
                        'is_active': True,
                        'app_version': app_version,
                        'os_version': os_version,
                    }
                )
            except Exception as e:
                # Log error but don't fail the login/registration
                print(f"Failed to register device token: {e}")
