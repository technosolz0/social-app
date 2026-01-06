from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from rest_framework.routers import DefaultRouter
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

# Import ViewSets
from apps.users.views import UserViewSet
from apps.content.views import PostViewSet, StoryViewSet
from apps.social.views import FollowViewSet, LikeViewSet, CommentViewSet
from apps.gamification.views import GamificationViewSet
from apps.activities.views import ActivityViewSet

# Create router
router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'posts', PostViewSet, basename='post')
router.register(r'stories', StoryViewSet, basename='story')
router.register(r'follows', FollowViewSet, basename='follow')
router.register(r'comments', CommentViewSet, basename='comment')
router.register(r'gamification', GamificationViewSet, basename='gamification')
router.register(r'activities', ActivityViewSet, basename='activity')

# Add nested routes for comments under posts
post_router = DefaultRouter()
post_router.register(r'comments', CommentViewSet, basename='post-comments')

def api_root(request):
    """Root API endpoint"""
    return JsonResponse({
        'message': 'Social App API',
        'version': '1.0.0',
        'documentation': request.build_absolute_uri('/api/docs/'),
        'endpoints': {
            'users': '/api/v1/users/',
            'posts': '/api/v1/posts/',
            'chat': '/api/v1/chat/',
            'gamification': '/api/v1/gamification/',
            'activities': '/api/v1/activities/',
        }
    })

urlpatterns = [
    # Root API endpoint
    path('', api_root, name='api-root'),

    # Admin
    path('admin/', admin.site.urls),

    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # DRF browsable API authentication
    path('api-auth/', include('rest_framework.urls')),

    # API v1
    path('api/v1/', include(router.urls)),

    # Nested routes for posts
    path('api/v1/posts/<uuid:post_id>/', include([
        path('comments/', CommentViewSet.as_view({
            'get': 'list',
            'post': 'create'
        }), name='post-comments'),
        path('likes/', LikeViewSet.as_view({
            'post': 'create',
            'delete': 'destroy'
        }), name='post-likes'),
    ])),

    # Chat endpoints
    path('api/v1/chat/', include('apps.chat.urls')),

    # Notifications endpoints
    path('api/v1/notifications/', include('apps.notifications.urls')),

    # Custom endpoints
    path('api/v1/likes/', LikeViewSet.as_view({'post': 'create', 'delete': 'destroy'})),
]
