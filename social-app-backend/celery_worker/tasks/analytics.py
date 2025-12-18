from ..celery_app import app

@app.task
def process_analytics():
    pass
