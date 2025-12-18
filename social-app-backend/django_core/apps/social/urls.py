from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def social_status(request):
    """Social service status endpoint."""
    return Response({
        'service': 'social',
        'status': 'operational',
        'features': ['follows', 'likes', 'comments', 'interactions']
    })

urlpatterns = [
    path('', social_status, name='social_status'),
]
