from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample
from .models import CustomUser, UserProfile
from .serializers import (UserSerializer, UserDetailSerializer,
                          UserRegistrationSerializer, UserProfileSerializer)

class UserViewSet(viewsets.ModelViewSet):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer

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

    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get current user profile"""
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
