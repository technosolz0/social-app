from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Follow, Like, Comment
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
        """Like a post"""
        post_id = request.data.get('post_id')

        like, created = Like.objects.get_or_create(
            user=request.user,
            post_id=post_id
        )

        return Response({
            'liked': created,
            'message': 'Liked' if created else 'Already liked'
        })

    def destroy(self, request, pk=None):
        """Unlike a post"""
        Like.objects.filter(
            user=request.user,
            post_id=pk
        ).delete()

        return Response({'message': 'Unliked successfully'})

class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects.select_related('user__profile').all()
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()

        # Filter by post
        post_id = self.request.query_params.get('post_id')
        if post_id:
            queryset = queryset.filter(post_id=post_id, parent=None)

        return queryset

    def create(self, request, *args, **kwargs):
        data = request.data.copy()
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user)

        return Response(serializer.data, status=status.HTTP_201_CREATED)
