from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
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

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        """Login endpoint"""
        email = request.data.get('email')
        password = request.data.get('password')

        user = authenticate(email=email, password=password)
        if user:
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
