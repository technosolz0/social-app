from celery import shared_task
from .services.video_processor import VideoProcessor
from .services.storage_service import StorageService
import os
import logging

logger = logging.getLogger(__name__)

@shared_task
def process_uploaded_video(post_id: str, video_url: str):
    """
    Complete video processing pipeline
    """
    from apps.content.models import Post

    try:
        post = Post.objects.get(id=post_id)

        # Download video
        video_path = VideoProcessor.download_video(video_url)
        if not video_path:
            raise Exception("Failed to download video")

        # Get video info
        info = VideoProcessor.get_video_info(video_path)
        post.duration = int(info.get('duration', 0))

        # Generate thumbnail
        thumbnail_path = VideoProcessor.generate_thumbnail(video_path)
        if thumbnail_path:
            thumbnail_url = StorageService.upload_to_s3(
                thumbnail_path,
                f'thumbnails/{post_id}.jpg'
            )
            post.thumbnail_url = thumbnail_url
            os.remove(thumbnail_path)

        # Transcode to multiple qualities
        qualities = ['360p', '480p', '720p']
        transcoded_urls = {}

        for quality in qualities:
            output_path = f'/tmp/{post_id}_{quality}.mp4'

            if VideoProcessor.transcode_video(video_path, output_path, quality):
                # Upload to S3
                s3_url = StorageService.upload_to_s3(
                    output_path,
                    f'videos/{post_id}/{quality}.mp4'
                )
                transcoded_urls[quality] = s3_url
                os.remove(output_path)

        # Store transcoded URLs in metadata
        post.metadata = {
            'transcoded_urls': transcoded_urls,
            'video_info': info
        }

        # Cleanup
        os.remove(video_path)

        post.save()

        logger.info(f"Video processing completed for post {post_id}")

    except Exception as e:
        logger.error(f"Video processing failed for post {post_id}: {e}")

        # Mark post as failed
        try:
            post = Post.objects.get(id=post_id)
            post.metadata = {'processing_error': str(e)}
            post.save()
        except:
            pass

@shared_task
def create_video_preview(post_id: str, video_url: str):
    """
    Create short preview/GIF from video
    """
    try:
        # Download video
        video_path = VideoProcessor.download_video(video_url)

        # Create 3-second preview
        preview_path = f'/tmp/{post_id}_preview.mp4'

        if VideoProcessor.trim_video(video_path, preview_path, 0, 3):
            # Upload preview
            preview_url = StorageService.upload_to_s3(
                preview_path,
                f'previews/{post_id}.mp4'
            )

            # Update post
            from apps.content.models import Post
            post = Post.objects.get(id=post_id)
            post.metadata = post.metadata or {}
            post.metadata['preview_url'] = preview_url
            post.save()

            os.remove(preview_path)

        os.remove(video_path)

    except Exception as e:
        logger.error(f"Preview creation failed: {e}")

@shared_task
def generate_video_sprites(post_id: str, video_url: str):
    """
    Generate sprite sheet for video scrubbing
    """
    try:
        import subprocess

        video_path = VideoProcessor.download_video(video_url)
        output_dir = f'/tmp/sprites_{post_id}'
        os.makedirs(output_dir, exist_ok=True)

        # Extract frames every 5 seconds
        cmd = [
            'ffmpeg',
            '-i', video_path,
            '-vf', 'fps=1/5,scale=160:90',
            f'{output_dir}/sprite_%03d.jpg'
        ]

        subprocess.run(cmd, capture_output=True, timeout=120)

        # Create sprite sheet (combine all frames)
        from PIL import Image

        frames = sorted([f for f in os.listdir(output_dir) if f.endswith('.jpg')])

        if frames:
            # Calculate grid size
            cols = 10
            rows = (len(frames) + cols - 1) // cols

            sprite_width = 160 * cols
            sprite_height = 90 * rows

            sprite = Image.new('RGB', (sprite_width, sprite_height))

            for idx, frame in enumerate(frames):
                img = Image.open(os.path.join(output_dir, frame))
                x = (idx % cols) * 160
                y = (idx // cols) * 90
                sprite.paste(img, (x, y))

            # Save sprite sheet
            sprite_path = f'/tmp/sprite_{post_id}.jpg'
            sprite.save(sprite_path, quality=85)

            # Upload to S3
            sprite_url = StorageService.upload_to_s3(
                sprite_path,
                f'sprites/{post_id}.jpg'
            )

            # Update post
            from apps.content.models import Post
            post = Post.objects.get(id=post_id)
            post.metadata = post.metadata or {}
            post.metadata['sprite_url'] = sprite_url
            post.save()

            os.remove(sprite_path)

        # Cleanup
        import shutil
        shutil.rmtree(output_dir)
        os.remove(video_path)

    except Exception as e:
        logger.error(f"Sprite generation failed: {e}")
