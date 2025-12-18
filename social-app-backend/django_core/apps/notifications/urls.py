from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def notifications_status(request):
    """Notifications service status endpoint."""
    return Response({
        'service': 'notifications',
        'status': 'operational',
        'features': ['push_notifications', 'email_notifications', 'in_app_notifications']
    })

urlpatterns = [
    path('', notifications_status, name='notifications_status'),
]
