from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import UserPoints, UserLevel, Badge, UserBadge, DailyQuest, UserQuest, PointsTransaction
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

    @action(detail=False, methods=['get', 'post'])
    def points(self, request):
        """Get or update user points"""
        user = request.user

        if request.method == 'GET':
            try:
                points_obj = user.points
                return Response({
                    'total_points': points_obj.total_points,
                    'current_level': user.level.current_level if hasattr(user, 'level') else 1,
                    'current_streak': points_obj.current_streak,
                })
            except:
                return Response({
                    'total_points': 0,
                    'current_level': 1,
                    'current_streak': 0,
                })

        elif request.method == 'POST':
            # Award points for activity
            activity_type = request.data.get('activity_type')
            points = request.data.get('points', 0)

            if not activity_type or points <= 0:
                return Response({'error': 'Invalid data'}, status=status.HTTP_400_BAD_REQUEST)

            # Get or create user points
            points_obj, created = UserPoints.objects.get_or_create(
                user=user,
                defaults={'total_points': 0, 'current_streak': 0}
            )

            # Update points
            points_obj.total_points += points
            points_obj.save()

            # Create transaction record
            PointsTransaction.objects.create(
                user=user,
                action_type=activity_type,
                points=points,
                description=f"Earned {points} points for {activity_type}",
            )

            # Update level
            level_obj, level_created = UserLevel.objects.get_or_create(
                user=user,
                defaults={'current_level': 1, 'tier': 'beginner', 'experience': 0}
            )

            # Simple level calculation: every 250 points = 1 level
            new_level = (points_obj.total_points // 250) + 1
            level_obj.current_level = max(level_obj.current_level, new_level)
            level_obj.save()

            return Response({
                'total_points': points_obj.total_points,
                'current_level': level_obj.current_level,
                'current_streak': points_obj.current_streak,
            })

    @action(detail=False, methods=['get', 'post'])
    def badges(self, request):
        """Get user badges or award a badge"""
        user = request.user

        if request.method == 'GET':
            user_badges = UserBadge.objects.filter(user=user).select_related('badge')
            badges_data = [{
                'id': str(ub.badge.id),
                'name': ub.badge.name,
                'description': ub.badge.description,
                'rarity': ub.badge.rarity,
                'icon_url': ub.badge.icon_url,
                'earned_at': ub.earned_at.isoformat(),
            } for ub in user_badges]

            return Response({'results': badges_data})

        elif request.method == 'POST':
            # Award a badge
            badge_id = request.data.get('badge_id')
            if not badge_id:
                return Response({'error': 'badge_id required'}, status=status.HTTP_400_BAD_REQUEST)

            try:
                badge = Badge.objects.get(id=badge_id)
                user_badge, created = UserBadge.objects.get_or_create(
                    user=user,
                    badge=badge,
                    defaults={'earned_at': timezone.now()}
                )

                if created:
                    return Response({
                        'message': 'Badge awarded',
                        'badge': {
                            'id': str(badge.id),
                            'name': badge.name,
                            'rarity': badge.rarity,
                        }
                    })
                else:
                    return Response({'message': 'Badge already earned'})

            except Badge.DoesNotExist:
                return Response({'error': 'Badge not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get'])
    def quests(self, request):
        """Get user quests with progress"""
        user = request.user
        today = timezone.now().date()

        # Get active quests
        active_quests = DailyQuest.objects.filter(
            is_active=True,
            start_date__lte=today,
            end_date__gte=today
        )

        quests_data = []
        for quest in active_quests:
            # Get or create user quest progress
            user_quest, created = UserQuest.objects.get_or_create(
                user=user,
                quest=quest,
                defaults={'progress': 0, 'is_completed': False}
            )

            quests_data.append({
                'id': str(quest.id),
                'title': quest.title,
                'description': quest.description,
                'category': quest.quest_type,
                'target': quest.target_value,
                'progress': user_quest.progress,
                'points': quest.points_reward,
                'completed': user_quest.is_completed,
            })

        return Response({'results': quests_data})

    @action(detail=False, methods=['patch'])
    def streak(self, request):
        """Update user streak"""
        user = request.user
        new_streak = request.data.get('streak', 0)

        points_obj, created = UserPoints.objects.get_or_create(
            user=user,
            defaults={'total_points': 0, 'current_streak': 0}
        )

        points_obj.current_streak = new_streak
        if new_streak > points_obj.longest_streak:
            points_obj.longest_streak = new_streak
        points_obj.save()

        return Response({
            'current_streak': points_obj.current_streak,
            'longest_streak': points_obj.longest_streak,
        })
