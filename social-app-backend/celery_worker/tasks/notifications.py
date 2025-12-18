from ..celery_app import app

@app.task
def send_notification():
    pass
