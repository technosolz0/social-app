from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .views import PushTokenViewSet

@api_view(['GET'])
def notifications_status(request):
    """Notifications service status endpoint."""
    return Response({
        'service': 'notifications',
        'status': 'operational',
        'features': ['push_notifications', 'email_notifications', 'in_app_notifications']
    })

router = DefaultRouter()
router.register(r'push-tokens', PushTokenViewSet, basename='push-token')

urlpatterns = [
    path('', notifications_status, name='notifications_status'),
    path('api/', include(router.urls)),
]
