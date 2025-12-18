"""
Initialize database with sample data
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from django.contrib.auth import get_user_model
from apps.gamification.models import Badge, DailyQuest
from datetime import date, timedelta

User = get_user_model()

def create_superuser():
    """Create admin user"""
    if not User.objects.filter(email='admin@example.com').exists():
        User.objects.create_superuser(
            username='admin',
            email='admin@example.com',
            password='admin123'
        )
        print("✅ Superuser created: admin@example.com / admin123")

def create_badges():
    """Create default badges"""
    badges_data = [
        {
            'name': 'Weekend Creator',
            'description': 'Posted content on the weekend',
            'badge_type': 'activity',
            'icon_url': 'https://example.com/badges/weekend.png',
            'criteria': {'posts_on_weekend': 5},
            'rarity': 'common'
        },
        {
            'name': 'Trend Spark',
            'description': 'Started a trending hashtag',
            'badge_type': 'content',
            'icon_url': 'https://example.com/badges/trend.png',
            'criteria': {'trending_hashtags': 1},
            'rarity': 'rare'
        },
        {
            'name': 'Filter Alchemist',
            'description': 'Used 50 different filters',
            'badge_type': 'content',
            'icon_url': 'https://example.com/badges/filter.png',
            'criteria': {'unique_filters': 50},
            'rarity': 'epic'
        },
        {
            'name': 'Daily Streak Master',
            'description': 'Maintained a 30-day login streak',
            'badge_type': 'activity',
            'icon_url': 'https://example.com/badges/streak.png',
            'criteria': {'login_streak': 30},
            'rarity': 'epic'
        },
        {
            'name': 'Viral Voyager',
            'description': 'Achieved 1M+ views on a post',
            'badge_type': 'special',
            'icon_url': 'https://example.com/badges/viral.png',
            'criteria': {'post_views': 1000000},
            'rarity': 'legendary'
        }
    ]
    
    for badge_data in badges_data:
        Badge.objects.get_or_create(
            name=badge_data['name'],
            defaults=badge_data
        )
    
    print(f"✅ Created {len(badges_data)} badges")

def create_daily_quests():
    """Create sample daily quests"""
    today = date.today()
    
    quests_data = [
        {
            'title': 'Daily Creator',
            'description': 'Post 2 pieces of content today',
            'quest_type': 'post_count',
            'target_value': 2,
            'points_reward': 50,
            'start_date': today,
            'end_date': today + timedelta(days=1)
        },
        {
            'title': 'Social Butterfly',
            'description': 'Comment on 5 posts',
            'quest_type': 'comment_count',
            'target_value': 5,
            'points_reward': 30,
            'start_date': today,
            'end_date': today + timedelta(days=1)
        },
        {
            'title': 'Explorer',
            'description': 'Watch 10 videos',
            'quest_type': 'view_count',
            'target_value': 10,
            'points_reward': 20,
            'start_date': today,
            'end_date': today + timedelta(days=1)
        }
    ]
    
    for quest_data in quests_data:
        DailyQuest.objects.get_or_create(
            title=quest_data['title'],
            defaults=quest_data
        )
    
    print(f"✅ Created {len(quests_data)} daily quests")

if __name__ == '__main__':
    print("🚀 Initializing database...")
    create_superuser()
    create_badges()
    create_daily_quests()
    print("✅ Database initialization complete!")
