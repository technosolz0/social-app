from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def gamification_status(request):
    """Gamification service status endpoint."""
    return Response({
        'service': 'gamification',
        'status': 'operational',
        'features': ['points', 'levels', 'badges', 'quests']
    })

urlpatterns = [
    path('', gamification_status, name='gamification_status'),
]
