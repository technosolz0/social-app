from django.contrib import admin
from django.urls import path, include
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

urlpatterns = [
    # Admin
    path('admin/', admin.site.urls),

    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # API v1
    path('api/v1/', include(router.urls)),

    # Custom endpoints
    path('api/v1/likes/', LikeViewSet.as_view({'post': 'create', 'delete': 'destroy'})),
]
