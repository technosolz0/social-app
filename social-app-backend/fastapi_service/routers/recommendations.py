from fastapi import APIRouter, Depends
import sys
import os

# Add the parent directory to Python path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.recommendation_engine import RecommendationEngine
from dependencies import verify_token

router = APIRouter()

@router.get("/users")
async def get_user_recommendations(
    user_data: dict = Depends(verify_token),
    limit: int = 20
):
    """
    Get user recommendations (who to follow)
    """
    engine = RecommendationEngine()
    users = await engine.recommend_users(
        user_id=user_data["user_id"],
        limit=limit
    )

    return {"users": users}

@router.get("/content")
async def get_content_recommendations(
    user_data: dict = Depends(verify_token),
    limit: int = 20
):
    """
    Get content recommendations based on user interests
    """
    engine = RecommendationEngine()
    posts = await engine.recommend_content(
        user_id=user_data["user_id"],
        limit=limit
    )

    return {"posts": posts}

@router.get("/hashtags")
async def get_hashtag_recommendations(
    user_data: dict = Depends(verify_token),
    limit: int = 10
):
    """
    Get trending hashtag recommendations
    """
    engine = RecommendationEngine()
    hashtags = await engine.recommend_hashtags(
        user_id=user_data["user_id"],
        limit=limit
    )

    return {"hashtags": hashtags}
