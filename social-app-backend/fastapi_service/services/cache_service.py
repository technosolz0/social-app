import json
from typing import List, Dict, Optional

class CacheService:
    """
    Redis caching service
    """

    @staticmethod
    async def get_cached_feed(redis_client, key: str) -> Optional[List[Dict]]:
        """Get cached feed"""
        try:
            cached = redis_client.get(key)
            if cached:
                return json.loads(cached)
        except:
            pass
        return None

    @staticmethod
    async def cache_feed(redis_client, key: str, data: List[Dict], ttl: int = 300):
        """Cache feed data"""
        try:
            redis_client.setex(key, ttl, json.dumps(data, default=str))
        except Exception as e:
            print(f"Cache error: {e}")
