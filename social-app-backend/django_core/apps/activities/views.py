from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from django.db.models import Count, Q
from datetime import datetime, timedelta

from .models import Activity
from .serializers import ActivitySerializer, ActivityCreateSerializer

class ActivityViewSet(viewsets.ModelViewSet):
    queryset = Activity.objects.all()
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['activity_type', 'post_id', 'target_user_id']
    ordering_fields = ['timestamp']
    ordering = ['-timestamp']

    def get_serializer_class(self):
        if self.action in ['create', 'bulk_create']:
            return ActivityCreateSerializer
        return ActivitySerializer

    def get_queryset(self):
        queryset = Activity.objects.select_related('user__profile')

        # Filter by current user unless admin
        if not self.request.user.is_staff:
            queryset = queryset.filter(user=self.request.user)

        return queryset

    @action(detail=False, methods=['post'])
    def bulk_create(self, request):
        """Create multiple activities at once"""
        activities_data = request.data.get('activities', [])
        created_activities = []

        for activity_data in activities_data:
            serializer = ActivityCreateSerializer(
                data=activity_data,
                context={'request': request}
            )
            if serializer.is_valid():
                activity = serializer.save()
                created_activities.append(activity)

        response_serializer = ActivitySerializer(created_activities, many=True)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get activity statistics"""
        user = request.user
        days = int(request.query_params.get('days', 7))

        since_date = datetime.now() - timedelta(days=days)

        stats = Activity.objects.filter(
            user=user,
            timestamp__gte=since_date
        ).aggregate(
            total_activities=Count('id'),
            post_views=Count('id', filter=Q(activity_type='post_view')),
            likes=Count('id', filter=Q(activity_type='post_like')),
            comments=Count('id', filter=Q(activity_type='comment')),
            shares=Count('id', filter=Q(activity_type='share')),
            searches=Count('id', filter=Q(activity_type='search')),
        )

        # Most active day
        most_active_day = Activity.objects.filter(
            user=user,
            timestamp__gte=since_date
        ).extra(
            select={'day': 'DATE(timestamp)'}
        ).values('day').annotate(
            count=Count('id')
        ).order_by('-count').first()

        stats['most_active_day'] = most_active_day['day'] if most_active_day else None
        stats['most_active_count'] = most_active_day['count'] if most_active_day else 0

        return Response(stats)

    @action(detail=False, methods=['get'])
    def recent_searches(self, request):
        """Get recent search queries"""
        limit = int(request.query_params.get('limit', 10))

        searches = Activity.objects.filter(
            user=request.user,
            activity_type='search'
        ).order_by('-timestamp')[:limit]

        search_queries = []
        seen_queries = set()

        for activity in searches:
            query = activity.metadata.get('query', '').strip()
            if query and query not in seen_queries:
                search_queries.append({
                    'query': query,
                    'timestamp': activity.timestamp,
                })
                seen_queries.add(query)

        return Response(search_queries)

    @action(detail=False, methods=['delete'])
    def clear_history(self, request):
        """Clear all user activities"""
        Activity.objects.filter(user=request.user).delete()
        return Response({'message': 'Activity history cleared'})
