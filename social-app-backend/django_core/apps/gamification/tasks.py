from celery import shared_task
from django.utils import timezone
from django.db.models import F
from datetime import date, timedelta
import logging

logger = logging.getLogger(__name__)

POINTS_CONFIG = {
    'upload_post': 50,
    'get_like': 1,
    'get_comment': 5,
    'comment_post': 2,      # New: points for commenting
    'reply_comment': 2,     # New: points for replying
    'follow_user': 10,      # New: points for following someone
    'daily_login': 10,
    'use_filter': 15,
    'invite_friend': 100,
    'complete_quest': 30,
    'streak_bonus': 20,
}

LEVEL_THRESHOLDS = {
    1: 0, 2: 100, 3: 250, 4: 500, 5: 750,
    10: 2000, 15: 5000, 20: 10000, 25: 20000,
    30: 50000, 35: 100000, 40: 200000
}

@shared_task
def award_points(user_id, action_type, points=None):
    """Award points to user for actions"""
    from apps.users.models import CustomUser
    from apps.gamification.models import UserPoints, PointsTransaction, UserLevel, GamificationConfig

    try:
        user = CustomUser.objects.get(id=user_id)
        user_points, _ = UserPoints.objects.get_or_create(user=user)

        # Get points from dynamic config if not provided explicitly
        points_to_award = points
        
        if points_to_award is None:
            # Try to get from database config first
            try:
                config = GamificationConfig.objects.get(key=action_type, is_active=True)
                points_to_award = config.points
            except GamificationConfig.DoesNotExist:
                # Fallback to static config
                points_to_award = POINTS_CONFIG.get(action_type, 0)
                
                # Auto-create config entry for future use if it doesn't exist at all
                if not GamificationConfig.objects.filter(key=action_type).exists():
                    GamificationConfig.objects.create(
                        key=action_type,
                        points=POINTS_CONFIG.get(action_type, 0),
                        description=f"Points for {action_type}"
                    )

        # Create transaction
        PointsTransaction.objects.create(
            user=user,
            action_type=action_type,
            points=points_to_award,
            description=f"Earned {points_to_award} points for {action_type}"
        )

        # Update total points
        user_points.total_points += points_to_award
        user_points.save()

        # Check for level up
        check_level_up.delay(str(user.id))

        logger.info(f"Awarded {points_to_award} points to user {user_id}")

    except Exception as e:
        logger.error(f"Error awarding points: {e}")

@shared_task
def check_level_up(user_id):
    """Check if user should level up based on points"""
    from apps.users.models import CustomUser
    from apps.gamification.models import UserPoints, UserLevel

    try:
        user = CustomUser.objects.get(id=user_id)
        user_points = UserPoints.objects.get(user=user)
        user_level, _ = UserLevel.objects.get_or_create(user=user)

        current_points = user_points.total_points
        current_level = user_level.current_level

        # Find the highest level user qualifies for
        new_level = current_level
        for level, threshold in sorted(LEVEL_THRESHOLDS.items()):
            if current_points >= threshold and level > current_level:
                new_level = level

        if new_level > current_level:
            user_level.current_level = new_level
            user_level.experience = current_points

            # Update tier
            if new_level >= 31:
                user_level.tier = 'influencer'
            elif new_level >= 21:
                user_level.tier = 'super_creator'
            elif new_level >= 11:
                user_level.tier = 'creator'
            else:
                user_level.tier = 'beginner'

            user_level.save()

            # Send notification
            send_level_up_notification.delay(str(user.id), new_level)

            logger.info(f"User {user_id} leveled up to {new_level}")

    except Exception as e:
        logger.error(f"Error checking level up: {e}")

@shared_task
def process_daily_logins():
    """Process daily login streaks and award points"""
    from apps.gamification.models import UserPoints
    from apps.users.models import CustomUser

    today = date.today()
    yesterday = today - timedelta(days=1)

    # Get users who logged in today but not processed yet
    active_users = CustomUser.objects.filter(
        last_login__date=today
    ).select_related('points')

    for user in active_users:
        user_points = user.points

        # Check streak
        if user_points.last_login_date == yesterday:
            user_points.current_streak += 1
        else:
            user_points.current_streak = 1

        # Update longest streak
        if user_points.current_streak > user_points.longest_streak:
            user_points.longest_streak = user_points.current_streak

        user_points.last_login_date = today
        user_points.save()

        # Award daily login points
        award_points.delay(str(user.id), 'daily_login')

        # Award streak bonus every 7 days
        if user_points.current_streak % 7 == 0:
            award_points.delay(str(user.id), 'streak_bonus', points=20 * (user_points.current_streak // 7))

@shared_task
def check_daily_quests():
    """Check and update daily quest progress"""
    from apps.gamification.models import DailyQuest, UserQuest
    from django.utils import timezone

    today = timezone.now().date()
    active_quests = DailyQuest.objects.filter(
        is_active=True,
        start_date__lte=today,
        end_date__gte=today
    )

    for quest in active_quests:
        # Check each user's progress
        user_quests = UserQuest.objects.filter(
            quest=quest,
            is_completed=False
        ).select_related('user')

        for user_quest in user_quests:
            # Check if target is reached
            if user_quest.progress >= quest.target_value:
                user_quest.is_completed = True
                user_quest.completed_at = timezone.now()
                user_quest.save()

                # Award points
                award_points.delay(
                    str(user_quest.user.id),
                    'complete_quest',
                    points=quest.points_reward
                )

@shared_task
def send_level_up_notification(user_id, new_level):
    """Send notification when user levels up"""
    from apps.notifications.services import NotificationService

    NotificationService.send_notification(
        user_id=user_id,
        notification_type='level_up',
        title='Level Up! 🎉',
        message=f'Congratulations! You reached Level {new_level}',
        data={'level': new_level}
    )
