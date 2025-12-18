from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, UserProfile

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ['username', 'email', 'is_verified', 'is_creator', 'created_at']
    list_filter = ['is_verified', 'is_creator', 'is_staff']
    search_fields = ['username', 'email']
    ordering = ['-created_at']

    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {
            'fields': ('phone', 'is_verified', 'is_creator')
        }),
    )

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'followers_count', 'following_count', 'posts_count', 'is_private']
    list_filter = ['is_private', 'gender']
    search_fields = ['user__username', 'user__email', 'bio']
    raw_id_fields = ['user']
