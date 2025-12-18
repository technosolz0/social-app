from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def content_status(request):
    """Content service status endpoint."""
    return Response({
        'service': 'content',
        'status': 'operational',
        'features': ['posts', 'stories', 'media_upload']
    })

urlpatterns = [
    path('', content_status, name='content_status'),
]
