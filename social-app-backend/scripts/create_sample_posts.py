#!/usr/bin/env python
"""
Create sample posts for testing the social app
"""
import os
import sys
import django
from datetime import timedelta
import random

# Add the django_core directory to the path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'django_core'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

django.setup()

from django.contrib.auth import get_user_model
from apps.content.models import Post
from apps.social.models import Like, Comment, Follow
from apps.users.models import UserProfile

User = get_user_model()

# Sample post data
sample_posts = [
    {
        'caption': 'Beautiful sunset at the beach! 🌅 The colors are absolutely stunning. Nature never ceases to amaze me with its beauty. #sunset #beach #nature #photography',
        'media_url': 'https://picsum.photos/800/600?random=1',
        'hashtags': ['sunset', 'beach', 'nature', 'photography'],
        'post_type': 'photo'
    },
    {
        'caption': 'Just finished an amazing workout! 💪 Feeling energized and ready to take on the day. Remember, consistency is key! #fitness #workout #motivation #health',
        'media_url': 'https://picsum.photos/800/600?random=2',
        'hashtags': ['fitness', 'workout', 'motivation', 'health'],
        'post_type': 'photo'
    },
    {
        'caption': 'Homemade pizza night! 🍕 Nothing beats the taste of fresh ingredients and a crispy crust. Who else loves cooking? #pizza #food #cooking #homemade',
        'media_url': 'https://picsum.photos/800/600?random=3',
        'hashtags': ['pizza', 'food', 'cooking', 'homemade'],
        'post_type': 'photo'
    },
    {
        'caption': 'City lights at night ✨ The urban jungle never sleeps, and neither do the dreamers. What\'s your favorite city? #city #night #lights #urban',
        'media_url': 'https://picsum.photos/800/600?random=4',
        'hashtags': ['city', 'night', 'lights', 'urban'],
        'post_type': 'photo'
    },
    {
        'caption': 'Coffee and books ☕📚 Perfect way to start the morning. Currently reading "The Alchemist" - such an inspiring story! #coffee #books #reading #morning',
        'media_url': 'https://picsum.photos/800/600?random=5',
        'hashtags': ['coffee', 'books', 'reading', 'morning'],
        'post_type': 'photo'
    },
    {
        'caption': 'Mountain hiking adventure! 🏔️ The view from the top was absolutely breathtaking. Nature truly is the best therapist. #hiking #mountains #adventure #nature',
        'media_url': 'https://picsum.photos/800/600?random=6',
        'hashtags': ['hiking', 'mountains', 'adventure', 'nature'],
        'post_type': 'photo'
    },
    {
        'caption': 'Art gallery visit 🎨 This piece really spoke to me. Art has the power to evoke emotions we didn\'t know we had. #art #gallery #creativity #inspiration',
        'media_url': 'https://picsum.photos/800/600?random=7',
        'hashtags': ['art', 'gallery', 'creativity', 'inspiration'],
        'post_type': 'photo'
    },
    {
        'caption': 'Garden fresh vegetables 🥕🥬 Nothing tastes better than food straight from the garden. Growing your own food is so rewarding! #garden #vegetables #organic #farming',
        'media_url': 'https://picsum.photos/800/600?random=8',
        'hashtags': ['garden', 'vegetables', 'organic', 'farming'],
        'post_type': 'photo'
    },
    {
        'caption': 'Coding late at night 💻 When the code finally works, it\'s the best feeling ever! Currently working on a Flutter project. #coding #programming #flutter #developer',
        'media_url': 'https://picsum.photos/800/600?random=9',
        'hashtags': ['coding', 'programming', 'flutter', 'developer'],
        'post_type': 'photo'
    },
    {
        'caption': 'Puppy cuddles 🐶 This little guy stole my heart! Pets bring so much joy to our lives. What\'s your favorite animal? #puppy #dog #pets #cute',
        'media_url': 'https://picsum.photos/800/600?random=10',
        'hashtags': ['puppy', 'dog', 'pets', 'cute'],
        'post_type': 'photo'
    },
    {
        'caption': 'Ocean waves 🌊 The sound of crashing waves is so therapeutic. Could listen to this all day! #ocean #waves #beach #relaxation',
        'media_url': 'https://picsum.photos/800/600?random=11',
        'hashtags': ['ocean', 'waves', 'beach', 'relaxation'],
        'post_type': 'photo'
    },
    {
        'caption': 'Bicycle ride through the park 🚴‍♂️ Perfect weather for a bike ride! Getting some fresh air and exercise. #cycling #park #exercise #outdoors',
        'media_url': 'https://picsum.photos/800/600?random=12',
        'hashtags': ['cycling', 'park', 'exercise', 'outdoors'],
        'post_type': 'photo'
    },
    {
        'caption': 'Star gazing tonight ✨ The night sky is full of wonders. Makes you feel so small yet connected to the universe. #stars #nightsky #astronomy #wonder',
        'media_url': 'https://picsum.photos/800/600?random=13',
        'hashtags': ['stars', 'nightsky', 'astronomy', 'wonder'],
        'post_type': 'photo'
    },
    {
        'caption': 'Fresh baked cookies 🍪 The smell of cookies baking is heavenly! Nothing beats homemade treats. #cookies #baking #homemade #sweet',
        'media_url': 'https://picsum.photos/800/600?random=14',
        'hashtags': ['cookies', 'baking', 'homemade', 'sweet'],
        'post_type': 'photo'
    },
    {
        'caption': 'Music concert vibes 🎵 Live music is the best! The energy, the crowd, the atmosphere - pure magic! #concert #music #live #energy',
        'media_url': 'https://picsum.photos/800/600?random=15',
        'hashtags': ['concert', 'music', 'live', 'energy'],
        'post_type': 'photo'
    }
]

def create_sample_posts():
    """Create sample posts for all users"""
    users = User.objects.all()
    if not users.exists():
        print("No users found. Please run create_users.py first.")
        return

    print(f"Creating sample posts for {users.count()} users...")

    # Create posts for each user
    for i, user in enumerate(users):
        # Create 2-4 posts per user
        num_posts = random.randint(2, 4)

        for j in range(num_posts):
            post_data = sample_posts[(i * num_posts + j) % len(sample_posts)]

            # Create the post
            post = Post.objects.create(
                user=user,
                post_type=post_data['post_type'],
                caption=post_data['caption'],
                media_url=post_data['media_url'],
                hashtags=post_data['hashtags']
            )

            # Add some random likes and comments
            other_users = [u for u in users if u != user]
            if other_users:
                # Add 0-5 likes
                num_likes = random.randint(0, min(5, len(other_users)))
                likers = random.sample(other_users, num_likes)
                for liker in likers:
                    Like.objects.get_or_create(user=liker, post=post)

                # Add 0-3 comments
                num_comments = random.randint(0, min(3, len(other_users)))
                commenters = random.sample(other_users, num_comments)
                sample_comments = [
                    "Amazing post! 😍",
                    "Love this! ❤️",
                    "So beautiful! 🌟",
                    "Great shot! 📸",
                    "Incredible! 🤩",
                    "This is awesome! 🔥",
                    "Perfect! 👏",
                    "Stunning! ✨",
                    "Love the colors! 🎨",
                    "So inspiring! 💫"
                ]

                for commenter in commenters:
                    Comment.objects.create(
                        user=commenter,
                        post=post,
                        text=random.choice(sample_comments)
                    )

            # Remove emojis for console output
            clean_caption = post.caption[:50].encode('ascii', 'ignore').decode('ascii')
            print(f"Created post by {user.username}: {clean_caption}...")

    # Create some follow relationships
    print("Creating follow relationships...")
    for user in users:
        # Each user follows 2-4 other users
        others = [u for u in users if u != user]
        if len(others) > 0:
            num_follows = min(random.randint(2, 4), len(others))
            to_follow = random.sample(others, num_follows)
            for followed_user in to_follow:
                Follow.objects.get_or_create(
                    follower=user,
                    following=followed_user
                )

    print("Sample data created successfully!")

if __name__ == '__main__':
    create_sample_posts()
