from django.contrib import admin
from .models import Follow, Like, Comment, Report

@admin.register(Follow)
class FollowAdmin(admin.ModelAdmin):
    list_display = ['follower', 'following', 'created_at']
    search_fields = ['follower__username', 'following__username']
    raw_id_fields = ['follower', 'following']
    date_hierarchy = 'created_at'

@admin.register(Like)
class LikeAdmin(admin.ModelAdmin):
    list_display = ['user', 'post', 'created_at']
    search_fields = ['user__username']
    raw_id_fields = ['user', 'post']
    date_hierarchy = 'created_at'

@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ['user', 'post', 'text_preview', 'likes_count', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__username', 'text']
    raw_id_fields = ['user', 'post', 'parent']
    date_hierarchy = 'created_at'

    def text_preview(self, obj):
        return obj.text[:50] + "..." if len(obj.text) > 50 else obj.text
    text_preview.short_description = "Comment"

@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ['reporter', 'content_type', 'category', 'status', 'created_at']
    list_filter = ['category', 'status', 'created_at']
    search_fields = ['reporter__username', 'description']
    raw_id_fields = ['reporter', 'reviewed_by']
    date_hierarchy = 'created_at'
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Report Information', {
            'fields': ('reporter', 'content_type', 'object_id', 'category', 'description')
        }),
        ('Status', {
            'fields': ('status', 'reviewed_by', 'reviewed_at', 'moderator_notes')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related(
            'reporter', 'reviewed_by', 'content_type'
        )
