#!/usr/bin/env python
"""
Script to create initial gamification data (badges, quests, etc.)
"""
import os
import sys
import django
from datetime import date, timedelta

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_core.config.settings.development')
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
django.setup()

from django_core.apps.gamification.models import Badge, DailyQuest

def create_badges():
    """Create initial badges"""
    badges_data = [
        {
            'name': 'Welcome Aboard',
            'description': 'Welcome to the community! You\'ve taken your first step.',
            'badge_type': 'activity',
            'icon_url': 'https://example.com/badges/welcome.png',
            'criteria': {'first_login': True},
            'rarity': 'common',
        },
        {
            'name': 'First Post',
            'description': 'You\'ve shared your first post with the world!',
            'badge_type': 'content',
            'icon_url': 'https://example.com/badges/first_post.png',
            'criteria': {'posts_count': 1},
            'rarity': 'common',
        },
        {
            'name': 'Social Butterfly',
            'description': 'You\'re building connections in the community.',
            'badge_type': 'social',
            'icon_url': 'https://example.com/badges/social.png',
            'criteria': {'followers_count': 10},
            'rarity': 'rare',
        },
        {
            'name': 'Content Creator',
            'description': 'You\'ve created 50 amazing posts!',
            'badge_type': 'content',
            'icon_url': 'https://example.com/badges/creator.png',
            'criteria': {'posts_count': 50},
            'rarity': 'epic',
        },
        {
            'name': 'Streak Master',
            'description': 'Consistency is key, and you\'re mastering it!',
            'badge_type': 'activity',
            'icon_url': 'https://example.com/badges/streak.png',
            'criteria': {'current_streak': 30},
            'rarity': 'epic',
        },
        {
            'name': 'Legendary Influencer',
            'description': 'You\'ve reached the pinnacle of social success!',
            'badge_type': 'special',
            'icon_url': 'https://example.com/badges/legendary.png',
            'criteria': {'followers_count': 10000},
            'rarity': 'legendary',
        },
    ]

    for badge_data in badges_data:
        badge, created = Badge.objects.get_or_create(
            name=badge_data['name'],
            defaults=badge_data
        )
        if created:
            print(f"Created badge: {badge.name}")
        else:
            print(f"Badge already exists: {badge.name}")

def create_daily_quests():
    """Create sample daily quests"""
    today = date.today()

    quests_data = [
        {
            'title': 'Daily Login',
            'description': 'Log in to the app today',
            'quest_type': 'daily',
            'target_value': 1,
            'points_reward': 10,
            'start_date': today,
            'end_date': today + timedelta(days=30),
        },
        {
            'title': 'Share Content',
            'description': 'Create and share a post with your followers',
            'quest_type': 'creative',
            'target_value': 1,
            'points_reward': 25,
            'start_date': today,
            'end_date': today + timedelta(days=30),
        },
        {
            'title': 'Engage with Community',
            'description': 'Like or comment on 5 different posts',
            'quest_type': 'social',
            'target_value': 5,
            'points_reward': 15,
            'start_date': today,
            'end_date': today + timedelta(days=30),
        },
        {
            'title': 'Build Connections',
            'description': 'Follow 3 new users',
            'quest_type': 'social',
            'target_value': 3,
            'points_reward': 20,
            'start_date': today,
            'end_date': today + timedelta(days=30),
        },
        {
            'title': 'Stay Active',
            'description': 'Maintain a 3-day login streak',
            'quest_type': 'achievement',
            'target_value': 3,
            'points_reward': 30,
            'start_date': today,
            'end_date': today + timedelta(days=30),
        },
    ]

    for quest_data in quests_data:
        quest, created = DailyQuest.objects.get_or_create(
            title=quest_data['title'],
            start_date=quest_data['start_date'],
            defaults=quest_data
        )
        if created:
            print(f"Created quest: {quest.title}")
        else:
            print(f"Quest already exists: {quest.title}")

def main():
    print("Creating gamification data...")

    try:
        create_badges()
        print("\nBadges created successfully!")

        create_daily_quests()
        print("\nDaily quests created successfully!")

        print("\nGamification data creation completed!")

    except Exception as e:
        print(f"Error creating gamification data: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()