from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['GET'])
def health_check(request):
    """
    Health check endpoint to verify the API is running.
    """
    return Response({
        'status': 'healthy',
        'message': 'Social App API is running successfully',
        'timestamp': request.META.get('HTTP_DATE', 'N/A')
    }, status=status.HTTP_200_OK)

urlpatterns = [
    path('', health_check, name='health_check'),
]
