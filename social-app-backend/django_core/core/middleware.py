from django.utils.deprecation import MiddlewareMixin
from django.core.cache import cache
import time

class RequestLoggingMiddleware(MiddlewareMixin):
    """
    Middleware to log requests
    """
    def process_request(self, request):
        request.start_time = time.time()

    def process_response(self, request, response):
        if hasattr(request, 'start_time'):
            duration = time.time() - request.start_time
            response['X-Request-Duration'] = f"{duration:.3f}s"
        return response

class RateLimitMiddleware(MiddlewareMixin):
    """
    Simple rate limiting middleware
    """
    def process_request(self, request):
        if request.user.is_authenticated:
            user_id = str(request.user.id)
            cache_key = f"rate_limit:{user_id}"

            # Get request count
            request_count = cache.get(cache_key, 0)

            # Allow 100 requests per minute
            if request_count > 100:
                from django.http import JsonResponse
                return JsonResponse(
                    {'error': 'Rate limit exceeded'},
                    status=429
                )

            # Increment counter
            cache.set(cache_key, request_count + 1, 60)
