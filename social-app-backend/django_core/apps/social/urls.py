from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .views import FollowViewSet, LikeViewSet, CommentViewSet

@api_view(['GET'])
def social_status(request):
    """Social service status endpoint."""
    return Response({
        'service': 'social',
        'status': 'operational',
        'features': ['follows', 'likes', 'comments', 'interactions']
    })

# Create router for viewsets
router = DefaultRouter()
router.register(r'follows', FollowViewSet, basename='follows')
router.register(r'likes', LikeViewSet, basename='likes')
router.register(r'comments', CommentViewSet, basename='comments')

urlpatterns = [
    path('', social_status, name='social_status'),
    path('', include(router.urls)),
]
