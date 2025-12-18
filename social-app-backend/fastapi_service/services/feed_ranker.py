import asyncpg
from typing import List, Dict
from datetime import datetime, timedelta
from ..config import settings

class FeedRanker:
    """
    Feed ranking service using engagement-based scoring
    """

    async def get_personalized_feed(self, user_id: str, page: int, limit: int) -> List[Dict]:
        """
        Generate personalized feed based on:
        - Following relationships
        - User interests
        - Engagement history
        - Content freshness
        """
        conn = await asyncpg.connect(settings.DATABASE_URL)

        try:
            offset = (page - 1) * limit

            # Get posts from following with ranking score
            query = """
                SELECT
                    p.*,
                    u.username,
                    up.avatar,
                    (
                        (p.likes_count * 1.0) +
                        (p.comments_count * 2.0) +
                        (p.shares_count * 3.0) +
                        (p.views_count * 0.1) -
                        (EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600.0)
                    ) as ranking_score
                FROM posts p
                JOIN users u ON p.user_id = u.id
                JOIN user_profiles up ON u.id = up.user_id
                WHERE p.user_id IN (
                    SELECT following_id FROM follows WHERE follower_id = $1
                )
                AND p.created_at > NOW() - INTERVAL '7 days'
                AND p.is_approved = true
                ORDER BY ranking_score DESC
                LIMIT $2 OFFSET $3
            """

            posts = await conn.fetch(query, user_id, limit, offset)

            return [dict(post) for post in posts]

        finally:
            await conn.close()

    async def get_trending_feed(self, time_window: str, page: int, limit: int) -> List[Dict]:
        """
        Get trending posts based on engagement velocity
        """
        conn = await asyncpg.connect(settings.DATABASE_URL)

        try:
            # Convert time window to hours
            hours_map = {"1h": 1, "6h": 6, "12h": 12, "24h": 24, "7d": 168}
            hours = hours_map.get(time_window, 24)

            offset = (page - 1) * limit

            query = """
                SELECT
                    p.*,
                    u.username,
                    up.avatar,
                    (
                        (p.likes_count * 1.5) +
                        (p.comments_count * 3.0) +
                        (p.shares_count * 5.0) +
                        (p.views_count * 0.2)
                    ) / (EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600.0 + 2) as trending_score
                FROM posts p
                JOIN users u ON p.user_id = u.id
                JOIN user_profiles up ON u.id = up.user_id
                WHERE p.created_at > NOW() - INTERVAL '$1 hours'
                AND p.is_approved = true
                ORDER BY trending_score DESC
                LIMIT $2 OFFSET $3
            """

            posts = await conn.fetch(query, hours, limit, offset)

            return [dict(post) for post in posts]

        finally:
            await conn.close()

    async def get_explore_feed(self, user_id: str, category: str, page: int, limit: int) -> List[Dict]:
        """
        Get diverse explore feed
        """
        conn = await asyncpg.connect(settings.DATABASE_URL)

        try:
            offset = (page - 1) * limit

            # Get diverse posts user hasn't seen
            query = """
                SELECT DISTINCT ON (p.id)
                    p.*,
                    u.username,
                    up.avatar
                FROM posts p
                JOIN users u ON p.user_id = u.id
                JOIN user_profiles up ON u.id = up.user_id
                WHERE p.user_id != $1
                AND p.created_at > NOW() - INTERVAL '30 days'
                AND p.is_approved = true
                AND NOT EXISTS (
                    SELECT 1 FROM likes WHERE post_id = p.id AND user_id = $1
                )
                ORDER BY p.id, RANDOM()
                LIMIT $2 OFFSET $3
            """

            posts = await conn.fetch(query, user_id, limit, offset)

            return [dict(post) for post in posts]

        finally:
            await conn.close()
