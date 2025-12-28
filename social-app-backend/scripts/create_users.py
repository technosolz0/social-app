#!/usr/bin/env python
"""
Create dummy users for testing
"""
import os
import sys
import django

# Add the django_core directory to the path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'django_core'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

django.setup()

from django.contrib.auth import get_user_model
from apps.users.models import UserProfile

User = get_user_model()

# Create some test users
users_data = [
    {'username': 'alice', 'email': 'alice@example.com', 'first_name': 'Alice', 'last_name': 'Smith'},
    {'username': 'bob', 'email': 'bob@example.com', 'first_name': 'Bob', 'last_name': 'Johnson'},
    {'username': 'charlie', 'email': 'charlie@example.com', 'first_name': 'Charlie', 'last_name': 'Brown'},
    {'username': 'diana', 'email': 'diana@example.com', 'first_name': 'Diana', 'last_name': 'Prince'},
    {'username': 'eve', 'email': 'eve@example.com', 'first_name': 'Eve', 'last_name': 'Adams'},
]

print("Creating dummy users...")

for user_data in users_data:
    if not User.objects.filter(username=user_data['username']).exists():
        user = User.objects.create_user(
            username=user_data['username'],
            email=user_data['email'],
            password='testpass123',
            first_name=user_data['first_name'],
            last_name=user_data['last_name']
        )
        # Create profile
        UserProfile.objects.create(
            user=user,
            bio=f'Hi, I am {user_data["first_name"]}! Welcome to my profile.',
            location='New York'
        )
        print(f'Created user: {user.username}')
    else:
        print(f'User {user_data["username"]} already exists')

print("Dummy users created successfully!")
