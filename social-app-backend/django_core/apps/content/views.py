from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.core.cache import cache
from .models import Post, Story
from .serializers import PostSerializer, PostCreateSerializer, StorySerializer
from .tasks import process_video_upload

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.select_related('user__profile').all()
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'create':
            return PostCreateSerializer
        return PostSerializer

    def get_queryset(self):
        queryset = super().get_queryset()

        # Filter by post type
        post_type = self.request.query_params.get('type')
        if post_type:
            queryset = queryset.filter(post_type=post_type)

        # Filter by user
        user_id = self.request.query_params.get('user_id')
        if user_id:
            queryset = queryset.filter(user_id=user_id)

        return queryset

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        post = serializer.save()

        # Process video asynchronously if video post
        if post.post_type == 'video':
            process_video_upload.delay(str(post.id), post.media_url)

        return Response(
            PostSerializer(post).data,
            status=status.HTTP_201_CREATED
        )

    @action(detail=False, methods=['get'])
    def feed(self, request):
        """Get personalized feed (following users)"""
        from django_core.apps.social.models import Follow

        following_users = Follow.objects.filter(
            follower=request.user
        ).values_list('following_id', flat=True)

        posts = Post.objects.filter(
            user_id__in=following_users
        ).select_related('user__profile').order_by('-created_at')[:50]

        serializer = PostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def trending(self, request):
        """Get trending posts"""
        # Try to get from cache first
        trending_ids = cache.get('trending_posts')

        if trending_ids:
            posts = Post.objects.filter(id__in=trending_ids).select_related('user__profile')
        else:
            # Fallback to recent popular posts
            posts = Post.objects.order_by(
                '-likes_count', '-comments_count'
            ).select_related('user__profile')[:50]

        serializer = PostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data)

class StoryViewSet(viewsets.ModelViewSet):
    queryset = Story.objects.select_related('user__profile').all()
    serializer_class = StorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        from django.utils import timezone
        from django_core.apps.social.models import Follow

        # Get stories from following users that haven't expired
        following_users = Follow.objects.filter(
            follower=self.request.user
        ).values_list('following_id', flat=True)

        return Story.objects.filter(
            user_id__in=following_users,
            expires_at__gt=timezone.now()
        ).order_by('-created_at')
