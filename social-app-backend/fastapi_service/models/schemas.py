from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class FeedPost(BaseModel):
    id: str
    user_id: str
    username: str
    avatar: Optional[str]
    post_type: str
    caption: Optional[str]
    media_url: str
    thumbnail_url: Optional[str]
    likes_count: int
    comments_count: int
    shares_count: int
    views_count: int
    created_at: datetime

class FeedResponse(BaseModel):
    posts: List[FeedPost]
    page: int
    total: int
    has_more: bool
