import subprocess
import os
import tempfile
import requests
from PIL import Image
import io
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

class VideoProcessor:
    """
    Video processing service using FFmpeg
    """

    @staticmethod
    def download_video(url: str) -> str:
        """Download video to temp file"""
        try:
            response = requests.get(url, stream=True)

            # Create temp file
            temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4')

            for chunk in response.iter_content(chunk_size=8192):
                temp_file.write(chunk)

            temp_file.close()
            return temp_file.name

        except Exception as e:
            logger.error(f"Video download error: {e}")
            return None

    @staticmethod
    def get_video_info(video_path: str) -> dict:
        """
        Get video information using ffprobe
        """
        try:
            cmd = [
                'ffprobe',
                '-v', 'quiet',
                '-print_format', 'json',
                '-show_format',
                '-show_streams',
                video_path
            ]

            result = subprocess.run(cmd, capture_output=True, text=True)

            if result.returncode == 0:
                import json
                info = json.loads(result.stdout)

                # Extract useful info
                video_stream = next(
                    (s for s in info['streams'] if s['codec_type'] == 'video'),
                    None
                )

                return {
                    'duration': float(info['format'].get('duration', 0)),
                    'size': int(info['format'].get('size', 0)),
                    'width': video_stream.get('width', 0) if video_stream else 0,
                    'height': video_stream.get('height', 0) if video_stream else 0,
                    'codec': video_stream.get('codec_name', '') if video_stream else '',
                    'fps': eval(video_stream.get('r_frame_rate', '0/1')) if video_stream else 0,
                }

            return {}

        except Exception as e:
            logger.error(f"Video info extraction error: {e}")
            return {}

    @staticmethod
    def generate_thumbnail(video_path: str, time_offset: float = 1.0) -> str:
        """
        Generate thumbnail from video at specific time
        """
        try:
            output_path = tempfile.NamedTemporaryFile(delete=False, suffix='.jpg').name

            cmd = [
                'ffmpeg',
                '-i', video_path,
                '-ss', str(time_offset),
                '-vframes', '1',
                '-vf', 'scale=640:-1',  # Resize to 640px width
                '-y',
                output_path
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                timeout=30
            )

            if result.returncode == 0 and os.path.exists(output_path):
                return output_path

            return None

        except Exception as e:
            logger.error(f"Thumbnail generation error: {e}")
            return None

    @staticmethod
    def transcode_video(
        input_path: str,
        output_path: str,
        resolution: str = '720p',
        bitrate: str = '2M',
        preset: str = 'medium'
    ) -> bool:
        """
        Transcode video to different quality/format

        Resolutions: 360p, 480p, 720p, 1080p
        """
        try:
            # Resolution mapping
            resolutions = {
                '360p': '640:360',
                '480p': '854:480',
                '720p': '1280:720',
                '1080p': '1920:1080'
            }

            scale = resolutions.get(resolution, '1280:720')

            cmd = [
                'ffmpeg',
                '-i', input_path,
                '-c:v', 'libx264',
                '-preset', preset,
                '-b:v', bitrate,
                '-vf', f'scale={scale}',
                '-c:a', 'aac',
                '-b:a', '128k',
                '-movflags', '+faststart',  # For web streaming
                '-y',
                output_path
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                timeout=300  # 5 minute timeout
            )

            return result.returncode == 0

        except Exception as e:
            logger.error(f"Video transcoding error: {e}")
            return False

    @staticmethod
    def create_hls_stream(input_path: str, output_dir: str) -> dict:
        """
        Create HLS stream with multiple quality variants
        """
        try:
            os.makedirs(output_dir, exist_ok=True)

            # Generate master playlist and variants
            variants = [
                {'name': '360p', 'width': 640, 'height': 360, 'bitrate': '800k'},
                {'name': '480p', 'width': 854, 'height': 480, 'bitrate': '1400k'},
                {'name': '720p', 'width': 1280, 'height': 720, 'bitrate': '2800k'},
            ]

            playlists = []

            for variant in variants:
                output_file = os.path.join(output_dir, f"{variant['name']}.m3u8")

                cmd = [
                    'ffmpeg',
                    '-i', input_path,
                    '-c:v', 'libx264',
                    '-b:v', variant['bitrate'],
                    '-vf', f"scale={variant['width']}:{variant['height']}",
                    '-c:a', 'aac',
                    '-b:a', '128k',
                    '-hls_time', '6',
                    '-hls_playlist_type', 'vod',
                    '-hls_segment_filename', os.path.join(output_dir, f"{variant['name']}_%03d.ts"),
                    '-y',
                    output_file
                ]

                result = subprocess.run(cmd, capture_output=True, timeout=300)

                if result.returncode == 0:
                    playlists.append({
                        'quality': variant['name'],
                        'playlist': output_file,
                        'bitrate': variant['bitrate']
                    })

            # Create master playlist
            master_playlist = os.path.join(output_dir, 'master.m3u8')
            with open(master_playlist, 'w') as f:
                f.write('#EXTM3U\n')
                f.write('#EXT-X-VERSION:3\n')

                for playlist in playlists:
                    f.write(f"#EXT-X-STREAM-INF:BANDWIDTH={int(playlist['bitrate'][:-1])*1000}\n")
                    f.write(f"{playlist['quality']}.m3u8\n")

            return {
                'master_playlist': master_playlist,
                'variants': playlists
            }

        except Exception as e:
            logger.error(f"HLS creation error: {e}")
            return {}

    @staticmethod
    def compress_video(input_path: str, output_path: str, target_size_mb: int = 50) -> bool:
        """
        Compress video to target file size
        """
        try:
            # Get video duration
            info = VideoProcessor.get_video_info(input_path)
            duration = info.get('duration', 0)

            if duration == 0:
                return False

            # Calculate target bitrate
            target_bitrate = int((target_size_mb * 8192) / duration)
            audio_bitrate = 128  # 128 kbps for audio
            video_bitrate = target_bitrate - audio_bitrate

            cmd = [
                'ffmpeg',
                '-i', input_path,
                '-c:v', 'libx264',
                '-b:v', f'{video_bitrate}k',
                '-maxrate', f'{video_bitrate}k',
                '-bufsize', f'{video_bitrate*2}k',
                '-c:a', 'aac',
                '-b:a', f'{audio_bitrate}k',
                '-y',
                output_path
            ]

            result = subprocess.run(cmd, capture_output=True, timeout=300)

            return result.returncode == 0

        except Exception as e:
            logger.error(f"Video compression error: {e}")
            return False

    @staticmethod
    def extract_audio(video_path: str, output_path: str) -> bool:
        """
        Extract audio from video
        """
        try:
            cmd = [
                'ffmpeg',
                '-i', video_path,
                '-vn',
                '-acodec', 'libmp3lame',
                '-b:a', '192k',
                '-y',
                output_path
            ]

            result = subprocess.run(cmd, capture_output=True, timeout=60)

            return result.returncode == 0

        except Exception as e:
            logger.error(f"Audio extraction error: {e}")
            return False

    @staticmethod
    def add_watermark(
        video_path: str,
        watermark_path: str,
        output_path: str,
        position: str = 'bottom-right'
    ) -> bool:
        """
        Add watermark to video
        Position: top-left, top-right, bottom-left, bottom-right, center
        """
        try:
            positions = {
                'top-left': '10:10',
                'top-right': 'W-w-10:10',
                'bottom-left': '10:H-h-10',
                'bottom-right': 'W-w-10:H-h-10',
                'center': '(W-w)/2:(H-h)/2'
            }

            overlay_pos = positions.get(position, 'W-w-10:H-h-10')

            cmd = [
                'ffmpeg',
                '-i', video_path,
                '-i', watermark_path,
                '-filter_complex', f'[1:v]scale=iw/4:-1[logo];[0:v][logo]overlay={overlay_pos}',
                '-codec:a', 'copy',
                '-y',
                output_path
            ]

            result = subprocess.run(cmd, capture_output=True, timeout=300)

            return result.returncode == 0

        except Exception as e:
            logger.error(f"Watermark error: {e}")
            return False

    @staticmethod
    def trim_video(
        video_path: str,
        output_path: str,
        start_time: float,
        end_time: float
    ) -> bool:
        """
        Trim video to specific time range
        """
        try:
            duration = end_time - start_time

            cmd = [
                'ffmpeg',
                '-i', video_path,
                '-ss', str(start_time),
                '-t', str(duration),
                '-c', 'copy',
                '-y',
                output_path
            ]

            result = subprocess.run(cmd, capture_output=True, timeout=60)

            return result.returncode == 0

        except Exception as e:
            logger.error(f"Video trim error: {e}")
            return False
