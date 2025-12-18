from django.contrib import admin
from .models import Activity

@admin.register(Activity)
class ActivityAdmin(admin.ModelAdmin):
    list_display = ['user', 'activity_type', 'timestamp', 'post_id', 'target_user_id']
    list_filter = ['activity_type', 'timestamp']
    search_fields = ['user__username', 'activity_type']
    readonly_fields = ['id', 'timestamp']
    ordering = ['-timestamp']

    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user')
