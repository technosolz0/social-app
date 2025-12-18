from django.contrib import admin
from .models import Post, Story

@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'post_type', 'likes_count', 'comments_count',
                    'views_count', 'is_approved', 'created_at']
    list_filter = ['post_type', 'is_approved', 'is_flagged', 'created_at']
    search_fields = ['user__username', 'caption', 'hashtags']
    raw_id_fields = ['user']
    date_hierarchy = 'created_at'

    actions = ['approve_posts', 'flag_posts']

    def approve_posts(self, request, queryset):
        queryset.update(is_approved=True, is_flagged=False)
    approve_posts.short_description = "Approve selected posts"

    def flag_posts(self, request, queryset):
        queryset.update(is_flagged=True)
    flag_posts.short_description = "Flag selected posts"

@admin.register(Story)
class StoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'media_type', 'views_count', 'expires_at', 'created_at']
    list_filter = ['media_type', 'created_at']
    search_fields = ['user__username']
    raw_id_fields = ['user']
    date_hierarchy = 'created_at'
