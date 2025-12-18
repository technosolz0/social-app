import asyncpg
from typing import List, Dict
from ..config import settings

class RecommendationEngine:
    """
    Recommendation engine for users and content
    """

    async def recommend_users(self, user_id: str, limit: int) -> List[Dict]:
        """
        Recommend users to follow based on:
        - Mutual connections
        - Similar interests
        - Popular creators
        """
        conn = await asyncpg.connect(settings.DATABASE_URL)

        try:
            query = """
                SELECT
                    u.id,
                    u.username,
                    up.avatar,
                    up.bio,
                    up.followers_count,
                    COUNT(DISTINCT f2.follower_id) as mutual_friends
                FROM users u
                JOIN user_profiles up ON u.id = up.user_id
                LEFT JOIN follows f1 ON u.id = f1.following_id
                LEFT JOIN follows f2 ON f1.follower_id = f2.following_id
                WHERE u.id != $1
                AND u.id NOT IN (
                    SELECT following_id FROM follows WHERE follower_id = $1
                )
                AND f2.follower_id = $1
                GROUP BY u.id, u.username, up.avatar, up.bio, up.followers_count
                ORDER BY mutual_friends DESC, up.followers_count DESC
                LIMIT $2
            """

            users = await conn.fetch(query, user_id, limit)

            return [dict(user) for user in users]

        finally:
            await conn.close()

    async def recommend_content(self, user_id: str, limit: int) -> List[Dict]:
        """
        Recommend content based on user history
        """
        # TODO: Implement content-based filtering
        return []

    async def recommend_hashtags(self, user_id: str, limit: int) -> List[Dict]:
        """
        Recommend trending hashtags
        """
        # TODO: Implement hashtag recommendations
        return []
