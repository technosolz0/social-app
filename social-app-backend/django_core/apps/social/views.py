from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.contenttypes.models import ContentType
from .models import Follow, Like, Comment, Report
from .serializers import FollowSerializer, LikeSerializer, CommentSerializer
from apps.users.models import CustomUser

class FollowViewSet(viewsets.ModelViewSet):
    queryset = Follow.objects.all()
    serializer_class = FollowSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['post'])
    def follow_user(self, request):
        """Follow a user"""
        following_id = request.data.get('user_id')

        if str(request.user.id) == following_id:
            return Response(
                {'error': 'Cannot follow yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )

        follow, created = Follow.objects.get_or_create(
            follower=request.user,
            following_id=following_id
        )

        if created:
            # Update follower counts
            request.user.profile.following_count += 1
            request.user.profile.save()

            try:
                following_user = CustomUser.objects.get(id=following_id)
                following_user.profile.followers_count += 1

                # Auto-verify if followers reach 1,000,000
                if not following_user.is_verified and following_user.profile.followers_count >= 1000000:
                    following_user.is_verified = True
                    following_user.save()

                following_user.profile.save()
            except CustomUser.DoesNotExist:
                pass

            return Response({'message': 'Followed successfully'})
        return Response({'message': 'Already following'})

    @action(detail=False, methods=['post'])
    def unfollow_user(self, request):
        """Unfollow a user"""
        following_id = request.data.get('user_id')

        deleted_count, _ = Follow.objects.filter(
            follower=request.user,
            following_id=following_id
        ).delete()

        if deleted_count > 0:
            # Update follower counts
            request.user.profile.following_count = max(0, request.user.profile.following_count - 1)
            request.user.profile.save()

            try:
                following_user = CustomUser.objects.get(id=following_id)
                following_user.profile.followers_count = max(0, following_user.profile.followers_count - 1)
                following_user.profile.save()
            except CustomUser.DoesNotExist:
                pass

        return Response({'message': 'Unfollowed successfully'})

class LikeViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = LikeSerializer  # Add serializer for drf-spectacular

    def create(self, request):
        """Like a post or comment"""
        post_id = request.data.get('post_id')
        comment_id = request.data.get('comment_id')

        try:
            if post_id:
                # Like a post
                from apps.content.models import Post
                post = Post.objects.get(id=post_id)
                like, created = Like.objects.get_or_create(
                    user=request.user,
                    content_type=ContentType.objects.get_for_model(Post),
                    object_id=post.id,
                    defaults={'content_object': post}
                )
            elif comment_id:
                # Like a comment
                from .models import Comment
                comment = Comment.objects.get(id=comment_id)
                like, created = Like.objects.get_or_create(
                    user=request.user,
                    content_type=ContentType.objects.get_for_model(Comment),
                    object_id=comment.id,
                    defaults={'content_object': comment}
                )

                # Update comment likes count
                if created:
                    comment.likes_count += 1
                else:
                    comment.likes_count -= 1
                comment.save()

            else:
                return Response(
                    {'error': 'Either post_id or comment_id is required'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            return Response({
                'liked': created,
                'message': 'Liked' if created else 'Unliked'
            })

        except (Post.DoesNotExist, Comment.DoesNotExist):
            return Response(
                {'error': 'Content not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    def destroy(self, request, pk=None):
        """Unlike a post or comment"""
        # For nested routes, pk is the post_id
        post_id = self.kwargs.get('post_id') or pk

        Like.objects.filter(
            user=request.user,
            post_id=post_id
        ).delete()

        return Response({'message': 'Unliked successfully'})

class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects.select_related('user__profile').all()
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()

        # Filter by post from URL parameter (for nested routes)
        post_id = self.kwargs.get('post_id')
        if post_id:
            queryset = queryset.filter(post_id=post_id, parent=None)
        else:
            # Filter by post from query parameter (for direct access)
            post_id = self.request.query_params.get('post_id')
            if post_id:
                queryset = queryset.filter(post_id=post_id, parent=None)

        return queryset

    def create(self, request, *args, **kwargs):
        data = request.data.copy()

        # Set post from URL parameter if available
        post_id = self.kwargs.get('post_id')
        if post_id:
            data['post'] = post_id

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user)

        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['get'])
    def replies(self, request, pk=None):
        """Get replies for a specific comment"""
        comment = self.get_object()
        replies = Comment.objects.filter(
            parent=comment
        ).select_related('user__profile').order_by('created_at')
        
        serializer = self.get_serializer(replies, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        """Like a comment"""
        comment = self.get_object()
        like, created = Like.objects.get_or_create(
            user=request.user,
            content_type=ContentType.objects.get_for_model(Comment),
            object_id=comment.id,
            defaults={'content_object': comment}
        )

        # Update comment likes count
        if created:
            comment.likes_count += 1
        else:
            comment.likes_count -= 1
        comment.save()

        return Response({
            'liked': created,
            'message': 'Liked' if created else 'Unliked'
        })

    @action(detail=True, methods=['delete'])
    def unlike(self, request, pk=None):
        """Unlike a comment"""
        comment = self.get_object()
        deleted_count, _ = Like.objects.filter(
            user=request.user,
            content_type=ContentType.objects.get_for_model(Comment),
            object_id=comment.id
        ).delete()

        if deleted_count > 0:
            comment.likes_count = max(0, comment.likes_count - 1)
            comment.save()

        return Response({'message': 'Unliked successfully'})

class ReportViewSet(viewsets.ModelViewSet):
    """ViewSet for handling content reports"""
    queryset = Report.objects.select_related('reporter__profile').all()
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            from .serializers import ReportCreateSerializer
            return ReportCreateSerializer
        from .serializers import ReportSerializer
        return ReportSerializer
    
    def get_queryset(self):
        """Users can only see their own reports"""
        if self.request.user.is_staff:
            # Staff can see all reports
            return super().get_queryset()
        return super().get_queryset().filter(reporter=self.request.user)
    
    def create(self, request, *args, **kwargs):
        """Create a new report"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Check if user already reported this content
        content_type = serializer.validated_data['content_type']
        object_id = serializer.validated_data['object_id']
        
        existing_report = Report.objects.filter(
            reporter=request.user,
            content_type=content_type,
            object_id=object_id
        ).first()
        
        if existing_report:
            return Response(
                {'error': 'You have already reported this content'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Save report with current user as reporter
        report = serializer.save(reporter=request.user)
        
        # Return full report data
        from .serializers import ReportSerializer
        return Response(
            ReportSerializer(report).data,
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=False, methods=['get'])
    def my_reports(self, request):
        """Get current user's submitted reports"""
        reports = self.get_queryset().filter(reporter=request.user)
        serializer = self.get_serializer(reports, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def pending(self, request):
        """Get pending reports (staff only)"""
        if not request.user.is_staff:
            return Response(
                {'error': 'Permission denied'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        reports = self.get_queryset().filter(status='pending')
        serializer = self.get_serializer(reports, many=True)
        return Response(serializer.data)
