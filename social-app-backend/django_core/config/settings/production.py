"""
Production settings for social app.
"""
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from .base import *

# Production specific settings
DEBUG = False

ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')

# Security settings
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# SSL/HTTPS settings
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# Database
DATABASES['default'].update({
    'NAME': os.getenv('DB_NAME'),
    'USER': os.getenv('DB_USER'),
    'PASSWORD': os.getenv('DB_PASSWORD'),
    'HOST': os.getenv('DB_HOST'),
    'PORT': os.getenv('DB_PORT', '5432'),
    'OPTIONS': {
        'sslmode': 'require',
    }
})

# CORS settings for production
CORS_ALLOWED_ORIGINS = os.getenv('CORS_ALLOWED_ORIGINS', '').split(',')

# Email configuration
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

# Caching - use Redis in production
CACHES['default']['LOCATION'] = os.getenv('CACHE_URL')

# Static files served by Nginx
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# Sentry error monitoring
if os.getenv('SENTRY_DSN'):
    sentry_sdk.init(
        dsn=os.getenv('SENTRY_DSN'),
        integrations=[DjangoIntegration()],
        traces_sample_rate=1.0,
        send_default_pii=True
    )

# Logging for production
LOGGING['handlers']['file']['level'] = 'WARNING'
LOGGING['loggers']['django']['level'] = 'WARNING'

# Add Sentry handler if configured
if os.getenv('SENTRY_DSN'):
    LOGGING['handlers']['sentry'] = {
        'level': 'ERROR',
        'class': 'sentry_sdk.integrations.logging.EventHandler',
    }
    LOGGING['root']['handlers'].append('sentry')
    LOGGING['loggers']['django']['handlers'].append('sentry')
