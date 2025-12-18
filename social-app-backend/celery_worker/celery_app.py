from celery import Celery
from celery.schedules import crontab
import os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

app = Celery('social_app')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

# Periodic tasks
app.conf.beat_schedule = {
    'process-daily-login-points': {
        'task': 'django_core.apps.gamification.tasks.process_daily_logins',
        'schedule': crontab(hour=0, minute=0),
    },
    'expire-stories': {
        'task': 'django_core.apps.content.tasks.expire_old_stories',
        'schedule': crontab(minute='*/15'),  # Every 15 minutes
    },
    'update-trending-content': {
        'task': 'django_core.apps.content.tasks.update_trending',
        'schedule': crontab(minute='*/30'),  # Every 30 minutes
    },
    'check-quest-completion': {
        'task': 'django_core.apps.gamification.tasks.check_daily_quests',
        'schedule': crontab(hour='*/1'),  # Every hour
    },
}
