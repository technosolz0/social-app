from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql://user:pass@localhost/social_app"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Django API
    DJANGO_API_URL: str = "http://localhost:8000"

    # ML Models
    MODEL_PATH: str = "./models"

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings()
