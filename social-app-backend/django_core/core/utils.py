from django.core.files.storage import default_storage
from django.conf import settings
import uuid
import os

def upload_to_s3(file, folder='uploads'):
    """
    Upload file to S3 and return URL
    """
    if not file:
        return None

    # Generate unique filename
    ext = os.path.splitext(file.name)[1]
    filename = f"{folder}/{uuid.uuid4()}{ext}"

    # Save file
    path = default_storage.save(filename, file)

    # Return URL
    if settings.USE_S3:
        return f"https://{settings.AWS_S3_CUSTOM_DOMAIN}/{path}"
    else:
        return f"{settings.MEDIA_URL}{path}"

def generate_username_from_email(email):
    """
    Generate username from email
    """
    username = email.split('@')[0]
    # Add random suffix if username exists
    from apps.users.models import CustomUser
    if CustomUser.objects.filter(username=username).exists():
        username = f"{username}_{uuid.uuid4().hex[:6]}"
    return username

def extract_hashtags(text):
    """
    Extract hashtags from text
    """
    import re
    hashtags = re.findall(r'#(\w+)', text)
    return list(set(hashtags))

def extract_mentions(text):
    """
    Extract user mentions from text
    """
    import re
    mentions = re.findall(r'@(\w+)', text)
    return list(set(mentions))
