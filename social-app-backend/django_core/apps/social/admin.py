from django.contrib import admin
from .models import Follow, Like, Comment

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
