from datetime import timezone
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.core.cache import cache
from .models import Post, Story
from .serializers import PostSerializer, PostCreateSerializer, StorySerializer
from .tasks import process_video_upload
from apps.social.models import Like, Comment

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
        from apps.social.models import Follow

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

    @action(detail=True, methods=['post', 'delete'])
    def like(self, request, pk=None):
        """Like/Unlike a post"""
        from apps.social.models import Like
        if request.method == 'DELETE':
            Like.objects.filter(
                user=request.user,
                post_id=pk
            ).delete()
            return Response({
                'liked': False,
                'message': 'Unliked successfully'
            }, status=status.HTTP_200_OK)
        else:
            like, created = Like.objects.get_or_create(
                user=request.user,
                post_id=pk
            )
            return Response({
                'liked': True,
                'message': 'Liked successfully'
            }, status=status.HTTP_200_OK)

    @action(detail=True, methods=['get'])
    def comments(self, request, pk=None):
        """Get comments for a post"""
        comments = Comment.objects.filter(
            post_id=pk,
            parent=None  # Only top-level comments
        ).select_related('user__profile').order_by('-created_at')

        comments_data = []
        for comment in comments:
            comments_data.append({
                'id': str(comment.id),
                'user': {
                    'id': str(comment.user.id),
                    'username': comment.user.username,
                    'avatar': comment.user.profile.avatar,
                },
                'text': comment.text,
                'likes_count': comment.likes_count,
                'replies_count': comment.replies.count(),
                'created_at': comment.created_at.isoformat(),
                'is_liked': Like.objects.filter(
                    user=request.user,
                    content_type=ContentType.objects.get_for_model(Comment),
                    object_id=comment.id
                ).exists(),
            })

        return Response({'results': comments_data})

    @action(detail=True, methods=['post'])
    def add_comment(self, request, pk=None):
        """Add a comment to a post"""
        text = request.data.get('text')
        parent_id = request.data.get('parent_id')

        if not text:
            return Response({'error': 'Text is required'}, status=status.HTTP_400_BAD_REQUEST)

        comment_data = {
            'user': request.user,
            'post_id': pk,
            'text': text,
        }

        if parent_id:
            try:
                parent_comment = Comment.objects.get(id=parent_id)
                comment_data['parent'] = parent_comment
            except Comment.DoesNotExist:
                return Response({'error': 'Parent comment not found'}, status=status.HTTP_404_NOT_FOUND)

        comment = Comment.objects.create(**comment_data)

        return Response({
            'id': str(comment.id),
            'user': {
                'id': str(comment.user.id),
                'username': comment.user.username,
                'avatar': comment.user.profile.avatar,
            },
            'text': comment.text,
            'likes_count': 0,
            'replies_count': 0,
            'created_at': comment.created_at.isoformat(),
            'is_liked': False,
        }, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'])
    def share(self, request, pk=None):
        """Share a post"""
        try:
            post = Post.objects.get(id=pk)
        except Post.DoesNotExist:
            return Response({'error': 'Post not found'}, status=status.HTTP_404_NOT_FOUND)

        # Create a shared post (you might want to create a separate Share model)
        # For now, we'll just increment share count
        post.shares_count += 1
        post.save()

        return Response({
            'message': 'Post shared successfully',
            'shares_count': post.shares_count,
        })

    @action(detail=False, methods=['get'])
    def explore(self, request):
        """Get explore feed (discover new content)"""
        # Get posts from users not followed, ordered by engagement
        from apps.social.models import Follow

        following_ids = Follow.objects.filter(
            follower=request.user
        ).values_list('following_id', flat=True)

        posts = Post.objects.exclude(
            user_id__in=following_ids
        ).exclude(
            user=request.user
        ).order_by(
            '-likes_count', '-comments_count', '-created_at'
        ).select_related('user__profile')[:50]

        serializer = PostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data)

class StoryViewSet(viewsets.ModelViewSet):
    queryset = Story.objects.select_related('user__profile').all()
    serializer_class = StorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        from django.utils import timezone
        from apps.social.models import Follow

        # Get stories from following users that haven't expired
        following_users = Follow.objects.filter(
            follower=self.request.user
        ).values_list('following_id', flat=True)

        return Story.objects.filter(
            user_id__in=following_users,
            expires_at__gt=timezone.now()
        ).order_by('-created_at')

    def create(self, request, *args, **kwargs):
        from datetime import timedelta
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Set expiration time (24 hours from now)
        story = serializer.save(
            user=request.user,
            expires_at=timezone.now() + timedelta(hours=24)
        )

        return Response(
            StorySerializer(story).data,
            status=status.HTTP_201_CREATED
        )

    @action(detail=True, methods=['post'])
    def view(self, request, pk=None):
        """Mark story as viewed"""
        try:
            story = Story.objects.get(id=pk)
        except Story.DoesNotExist:
            return Response({'error': 'Story not found'}, status=status.HTTP_404_NOT_FOUND)

        # Add user to viewed_by if not already there
        if request.user not in story.viewed_by.all():
            story.viewed_by.add(request.user)
            story.views_count += 1
            story.save()

        return Response({
            'message': 'Story viewed',
            'views_count': story.views_count,
        })

    @action(detail=False, methods=['get'])
    def my_stories(self, request):
        """Get current user's stories"""
        stories = Story.objects.filter(
            user=request.user,
            expires_at__gt=timezone.now()
        ).order_by('-created_at')

        serializer = StorySerializer(stories, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def highlights(self, request):
        """Get story highlights (featured stories)"""
        # Get popular recent stories
        stories = Story.objects.filter(
            expires_at__gt=timezone.now(),
            views_count__gte=10  # Stories with at least 10 views
        ).order_by('-views_count', '-created_at')[:20]

        serializer = StorySerializer(stories, many=True, context={'request': request})
        return Response(serializer.data)
