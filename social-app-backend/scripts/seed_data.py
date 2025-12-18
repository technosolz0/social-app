"""
Seed database with test data
"""
import os
import sys
import django
from faker import Faker
import random

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from django.contrib.auth import get_user_model
from apps.content.models import Post
from apps.social.models import Follow, Like, Comment

User = get_user_model()
fake = Faker()

def create_users(count=50):
    """Create test users"""
    users = []
    for i in range(count):
        try:
            user = User.objects.create_user(
                username=fake.user_name() + str(i),
                email=fake.email(),
                password='testpass123'
            )
            
            # Update profile
            user.profile.bio = fake.text(max_nb_chars=200)
            user.profile.location = fake.city()
            user.profile.save()
            
            users.append(user)
        except:
            pass
    
    print(f"✅ Created {len(users)} users")
    return users

def create_posts(users, count=200):
    """Create test posts"""
    post_types = ['photo', 'video', 'reel']
    posts = []
    
    for _ in range(count):
        user = random.choice(users)
        post = Post.objects.create(
            user=user,
            post_type=random.choice(post_types),
            caption=fake.text(max_nb_chars=500),
            media_url=fake.image_url(),
            thumbnail_url=fake.image_url(),
            hashtags=[f"#{fake.word()}" for _ in range(random.randint(1, 5))],
            likes_count=random.randint(0, 1000),
            comments_count=random.randint(0, 100),
            views_count=random.randint(100, 10000)
        )
        posts.append(post)
    
    print(f"✅ Created {len(posts)} posts")
    return posts

def create_follows(users, count=500):
    """Create follow relationships"""
    created = 0
    for _ in range(count):
        follower = random.choice(users)
        following = random.choice(users)
        
        if follower != following:
            Follow.objects.get_or_create(
                follower=follower,
                following=following
            )
            created += 1
    
    print(f"✅ Created {created} follows")

def create_likes(users, posts, count=1000):
    """Create likes"""
    created = 0
    for _ in range(count):
        user = random.choice(users)
        post = random.choice(posts)
        
        Like.objects.get_or_create(
            user=user,
            post=post
        )
        created += 1
    
    print(f"✅ Created {created} likes")

def create_comments(users, posts, count=500):
    """Create comments"""
    for _ in range(count):
        user = random.choice(users)
        post = random.choice(posts)
        
        Comment.objects.create(
            user=user,
            post=post,
            text=fake.text(max_nb_chars=200)
        )
    
    print(f"✅ Created {count} comments")

if __name__ == '__main__':
    print("🌱 Seeding database with test data...")
    users = create_users(50)
    posts = create_posts(users, 200)
    create_follows(users, 500)
    create_likes(users, posts, 1000)
    create_comments(users, posts, 500)
    print("✅ Database seeding complete!")
