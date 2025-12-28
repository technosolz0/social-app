from fastapi import APIRouter, Depends, BackgroundTasks, HTTPException
from typing import Optional
import requests
import os
import sys

# Add the parent directory to Python path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dependencies import verify_token

router = APIRouter()

# Django API base URL
DJANGO_API_URL = os.getenv("DJANGO_API_URL", "http://django:8000")

@router.post("/track")
async def track_event(
    event_type: str,
    event_data: dict,
    background_tasks: BackgroundTasks,
    user_data: dict = Depends(verify_token)
):
    """
    Track user events for analytics
    """
    # Process analytics in background
    background_tasks.add_task(
        process_analytics_event,
        user_id=user_data["user_id"],
        event_type=event_type,
        event_data=event_data,
        token=user_data.get("token")
    )

    return {"status": "tracked"}

async def process_analytics_event(user_id: str, event_type: str, event_data: dict, token: str = None):
    """Process analytics event by storing in Django Activity model"""
    try:
        # Map event_type to activity_type
        activity_type_mapping = {
            'post_view': 'post_view',
            'post_like': 'post_like',
            'story_view': 'story_view',
            'profile_view': 'profile_view',
            'search': 'search',
            'message_sent': 'message_sent',
            'login': 'login',
            'video_watch': 'video_watch',
            'follow': 'follow',
            'comment': 'comment',
            'share': 'share',
        }

        activity_type = activity_type_mapping.get(event_type, event_type)

        # Prepare activity data
        activity_data = {
            'activity_type': activity_type,
            'metadata': event_data,
        }

        # Add optional fields if present
        if 'post_id' in event_data:
            activity_data['post_id'] = event_data['post_id']
        if 'story_id' in event_data:
            activity_data['story_id'] = event_data['story_id']
        if 'target_user_id' in event_data:
            activity_data['target_user_id'] = event_data['target_user_id']

        # Send to Django API
        headers = {}
        if token:
            headers['Authorization'] = f'Bearer {token}'

        response = requests.post(
            f"{DJANGO_API_URL}/api/v1/activities/",
            json=activity_data,
            headers=headers,
            timeout=5
        )

        if response.status_code not in [200, 201]:
            print(f"Failed to store activity: {response.status_code} - {response.text}")

    except Exception as e:
        print(f"Error processing analytics event: {e}")

@router.get("/user-engagement")
async def get_user_engagement(
    user_data: dict = Depends(verify_token),
    days: int = 7
):
    """
    Get user engagement metrics
    """
    # TODO: Fetch from analytics database
    return {
        "views": 1250,
        "likes": 450,
        "comments": 89,
        "shares": 23,
        "followers_gained": 12,
        "engagement_rate": 8.5
    }
