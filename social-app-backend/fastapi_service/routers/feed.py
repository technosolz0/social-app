from fastapi import APIRouter, Depends, Query
from typing import List, Optional
import sys
import os

# Add the parent directory to Python path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.feed_ranker import FeedRanker
from services.cache_service import CacheService
from models.schemas import FeedPost, FeedResponse
from dependencies import verify_token, get_redis

router = APIRouter()

@router.get("/for-you", response_model=FeedResponse)
async def get_for_you_feed(
    user_data: dict = Depends(verify_token),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    redis_client = Depends(get_redis)
):
    """
    Get personalized 'For You' feed using ML ranking
    """
    user_id = user_data["user_id"]

    # Check cache first
    cache_key = f"feed:for_you:{user_id}:{page}"
    cached_feed = await CacheService.get_cached_feed(redis_client, cache_key)

    if cached_feed:
        return FeedResponse(
            posts=cached_feed,
            page=page,
            total=len(cached_feed),
            has_more=True
        )

    # Generate personalized feed
    feed_ranker = FeedRanker()
    posts = await feed_ranker.get_personalized_feed(
        user_id=user_id,
        page=page,
        limit=limit
    )

    # Cache for 5 minutes
    await CacheService.cache_feed(redis_client, cache_key, posts, ttl=300)

    return FeedResponse(
        posts=posts,
        page=page,
        total=len(posts),
        has_more=len(posts) == limit
    )

@router.get("/trending", response_model=FeedResponse)
async def get_trending_feed(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    time_window: str = Query("24h", regex="^(1h|6h|12h|24h|7d)$"),
    redis_client = Depends(get_redis)
):
    """
    Get trending posts based on engagement metrics
    """
    cache_key = f"feed:trending:{time_window}:{page}"
    cached_feed = await CacheService.get_cached_feed(redis_client, cache_key)

    if cached_feed:
        return FeedResponse(posts=cached_feed, page=page, total=len(cached_feed), has_more=True)

    feed_ranker = FeedRanker()
    posts = await feed_ranker.get_trending_feed(
        time_window=time_window,
        page=page,
        limit=limit
    )

    # Cache for 10 minutes
    await CacheService.cache_feed(redis_client, cache_key, posts, ttl=600)

    return FeedResponse(posts=posts, page=page, total=len(posts), has_more=len(posts) == limit)

@router.get("/explore")
async def get_explore_feed(
    user_data: dict = Depends(verify_token),
    category: Optional[str] = None,
    page: int = 1,
    limit: int = 20
):
    """
    Get explore feed with diverse content
    """
    feed_ranker = FeedRanker()
    posts = await feed_ranker.get_explore_feed(
        user_id=user_data["user_id"],
        category=category,
        page=page,
        limit=limit
    )

    return {"posts": posts, "page": page, "total": len(posts)}
