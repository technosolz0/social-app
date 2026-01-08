"""
Development settings for social app.
"""
from .base import *

# Development specific settings
DEBUG = True

ALLOWED_HOSTS = ['localhost', '127.0.0.1', '0.0.0.0', '192.168.43.227', '10.194.199.167', '10.129.254.167']

# Database - Using SQLite for local development
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}


# CORS settings for development
CORS_ALLOWED_ORIGINS += [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    "http://localhost:5173",  # Vite dev server
    "http://127.0.0.1:5173",
]

# REST Framework - Add session authentication for DRF browsable API
REST_FRAMEWORK['DEFAULT_AUTHENTICATION_CLASSES'] = (
    'rest_framework.authentication.SessionAuthentication',
    'rest_framework_simplejwt.authentication.JWTAuthentication',
)

# Email backend for development (console)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Disable throttling in development
REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
    'anon': '1000/hour',
    'user': '10000/hour'
}

# Channels - Using in-memory backend for local development
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer',
    },
}

# Cache - Using in-memory cache for local development
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    }
}

# Celery - Using in-memory broker for local development
CELERY_BROKER_URL = 'memory://'
CELERY_RESULT_BACKEND = 'cache+memory://'

# Development logging - reduced verbosity
LOGGING['handlers']['console']['level'] = 'INFO'
LOGGING['loggers']['django']['level'] = 'INFO'
LOGGING['loggers']['django.template'] = {
    'handlers': ['console'],
    'level': 'WARNING',
    'propagate': False,
}
LOGGING['loggers']['django.server'] = {
    'handlers': ['console'],
    'level': 'INFO',
    'propagate': False,
}
