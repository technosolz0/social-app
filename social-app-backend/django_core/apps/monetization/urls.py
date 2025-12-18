from django.urls import path
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def monetization_status(request):
    """Monetization service status endpoint."""
    return Response({
        'service': 'monetization',
        'status': 'operational',
        'features': ['wallets', 'transactions', 'gifts']
    })

urlpatterns = [
    path('', monetization_status, name='monetization_status'),
]
