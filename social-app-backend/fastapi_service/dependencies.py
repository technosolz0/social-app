from fastapi import Header, HTTPException
import redis
import asyncpg
from .config import settings

# Redis connection pool
redis_pool = redis.ConnectionPool.from_url(settings.REDIS_URL)

async def get_redis():
    return redis.Redis(connection_pool=redis_pool)

async def get_db():
    """Get database connection"""
    conn = await asyncpg.connect(settings.DATABASE_URL)
    try:
        yield conn
    finally:
        await conn.close()

async def verify_token(authorization: str = Header(None)):
    """Verify JWT token from Django"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    # TODO: Verify JWT token with Django
    # For now, just extract user_id from token
    token = authorization.replace("Bearer ", "")

    # This is simplified - implement proper JWT verification
    return {"user_id": "sample_user_id"}
