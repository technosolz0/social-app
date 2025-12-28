from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import UserPoints, UserLevel, Badge, UserBadge, DailyQuest
from .serializers import (UserPointsSerializer, UserLevelSerializer,
                          BadgeSerializer, UserBadgeSerializer, DailyQuestSerializer)

class GamificationViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = UserPointsSerializer  # Add serializer for drf-spectacular

    @action(detail=False, methods=['get'])
    def my_stats(self, request):
        """Get current user's gamification stats"""
        user = request.user

        try:
            points = UserPointsSerializer(user.points).data
            level = UserLevelSerializer(user.level).data
            badges = UserBadgeSerializer(user.badges.all(), many=True).data

            return Response({
                'points': points,
                'level': level,
                'badges': badges,
            })
        except Exception as e:
            return Response({'error': str(e)}, status=400)

    @action(detail=False, methods=['get'])
    def leaderboard(self, request):
        """Get points leaderboard"""
        top_users = UserPoints.objects.select_related(
            'user__profile'
        ).order_by('-total_points')[:100]

        leaderboard_data = [{
            'rank': idx + 1,
            'user_id': str(up.user.id),
            'username': up.user.username,
            'avatar': up.user.profile.avatar,
            'points': up.total_points,
            'level': up.user.level.current_level if hasattr(up.user, 'level') else 1,
        } for idx, up in enumerate(top_users)]

        return Response(leaderboard_data)

    @action(detail=False, methods=['get'])
    def daily_quests(self, request):
        """Get active daily quests"""
        from django.utils import timezone
        today = timezone.now().date()

        quests = DailyQuest.objects.filter(
            is_active=True,
            start_date__lte=today,
            end_date__gte=today
        )

        serializer = DailyQuestSerializer(
            quests, many=True, context={'request': request}
        )
        return Response(serializer.data)
