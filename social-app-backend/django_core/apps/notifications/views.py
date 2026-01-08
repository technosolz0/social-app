from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination
from django.utils import timezone
from .models import Notification, PushToken, NotificationPreference
from .serializers import (
    NotificationSerializer,
    PushTokenSerializer,
    NotificationPreferenceSerializer
)


class NotificationPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = NotificationPagination

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)

    def get_serializer_class(self):
        if self.action == 'list':
            return NotificationSerializer
        return NotificationSerializer

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications"""
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'unread_count': count})

    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark notification as read"""
        try:
            notification = self.get_queryset().get(pk=pk)
            notification.mark_as_read()
            return Response({'message': 'Notification marked as read'})
        except Notification.DoesNotExist:
            return Response(
                {'error': 'Notification not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        """Mark all notifications as read"""
        self.get_queryset().filter(is_read=False).update(
            is_read=True,
            read_at=timezone.now()
        )
        return Response({'message': 'All notifications marked as read'})

    @action(detail=False, methods=['delete'])
    def clear_all(self, request):
        """Delete all notifications"""
        self.get_queryset().delete()
        return Response({'message': 'All notifications cleared'})


class PushTokenViewSet(viewsets.ModelViewSet):
    serializer_class = PushTokenSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PushToken.objects.filter(user=self.request.user, is_active=True)

    @action(detail=False, methods=['post'])
    def register(self, request):
        """Register a device push token"""
        token = request.data.get('token')
        device_type = request.data.get('device_type', 'android')
        device_id = request.data.get('device_id', '')
        app_version = request.data.get('app_version', '')
        os_version = request.data.get('os_version', '')

        if not token:
            return Response(
                {'error': 'Token is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create or update push token
        push_token, created = PushToken.objects.update_or_create(
            user=request.user,
            device_id=device_id,
            defaults={
                'token': token,
                'device_type': device_type,
                'is_active': True,
                'app_version': app_version,
                'os_version': os_version,
            }
        )

        return Response({
            'message': 'Token registered successfully',
            'created': created,
        })

    @action(detail=False, methods=['post'])
    def unregister(self, request):
        """Unregister a device push token"""
        device_id = request.data.get('device_id')

        if device_id:
            PushToken.objects.filter(
                user=request.user,
                device_id=device_id
            ).update(is_active=False)
        else:
            # Unregister all tokens for user
            PushToken.objects.filter(user=request.user).update(is_active=False)

        return Response({'message': 'Token unregistered successfully'})

    @action(detail=False, methods=['get'])
    def active_tokens(self, request):
        """Get all active push tokens for user"""
        tokens = self.get_queryset()
        serializer = self.get_serializer(tokens, many=True)
        return Response(serializer.data)


class NotificationPreferenceViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationPreferenceSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return NotificationPreference.objects.filter(user=self.request.user)

    def get_object(self):
        # Return user's preference or create default if doesn't exist
        obj, created = NotificationPreference.objects.get_or_create(
            user=self.request.user,
            defaults={}
        )
        return obj

    @action(detail=False, methods=['post'])
    def update_preferences(self, request):
        """Update notification preferences"""
        preference, created = NotificationPreference.objects.get_or_create(
            user=request.user,
            defaults={}
        )

        serializer = self.get_serializer(preference, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'])
    def update_quiet_hours(self, request):
        """Update quiet hours settings"""
        preference, created = NotificationPreference.objects.get_or_create(
            user=request.user,
            defaults={}
        )

        quiet_hours_enabled = request.data.get('quiet_hours_enabled', False)
        quiet_hours_start = request.data.get('quiet_hours_start')
        quiet_hours_end = request.data.get('quiet_hours_end')

        preference.quiet_hours_enabled = quiet_hours_enabled
        if quiet_hours_start:
            preference.quiet_hours_start = quiet_hours_start
        if quiet_hours_end:
            preference.quiet_hours_end = quiet_hours_end

        preference.save()

        serializer = self.get_serializer(preference)
        return Response(serializer.data)
