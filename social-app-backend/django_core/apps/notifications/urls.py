from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .views import (
    NotificationViewSet,
    PushTokenViewSet,
    NotificationPreferenceViewSet
)

@api_view(['GET'])
def notifications_status(request):
    """Notifications service status endpoint."""
    return Response({
        'service': 'notifications',
        'status': 'operational',
        'features': [
            'push_notifications',
            'email_notifications',
            'in_app_notifications',
            'notification_preferences',
            'real_time_delivery'
        ]
    })

router = DefaultRouter()
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'push-tokens', PushTokenViewSet, basename='push-token')
router.register(r'preferences', NotificationPreferenceViewSet, basename='notification-preference')

urlpatterns = [
    path('', notifications_status, name='notifications_status'),
    path('api/', include(router.urls)),
]
