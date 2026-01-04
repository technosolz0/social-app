import boto3
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

class StorageService:
    """
    Cloud storage service (S3)
    """

    @staticmethod
    def get_s3_client():
        return boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_S3_REGION_NAME
        )

    @staticmethod
    def upload_to_s3(file_path: str, s3_key: str) -> str:
        """
        Upload file to S3 and return URL
        """
        try:
            s3 = StorageService.get_s3_client()

            with open(file_path, 'rb') as f:
                s3.upload_fileobj(
                    f,
                    settings.AWS_STORAGE_BUCKET_NAME,
                    s3_key,
                    ExtraArgs={'ACL': 'public-read'}
                )

            url = f"https://{settings.AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com/{s3_key}"
            return url

        except Exception as e:
            logger.error(f"S3 upload error: {e}")
            return None

    @staticmethod
    def delete_from_s3(s3_key: str) -> bool:
        """
        Delete file from S3
        """
        try:
            s3 = StorageService.get_s3_client()
            s3.delete_object(
                Bucket=settings.AWS_STORAGE_BUCKET_NAME,
                Key=s3_key
            )
            return True
        except Exception as e:
            logger.error(f"S3 delete error: {e}")
            return False
