from django.contrib import admin
from .models import UserWallet, Transaction, Gift

@admin.register(UserWallet)
class UserWalletAdmin(admin.ModelAdmin):
    list_display = ['user', 'coins_balance', 'total_earned', 'total_spent']
    search_fields = ['user__username']
    raw_id_fields = ['user']
    ordering = ['-coins_balance']

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ['user', 'transaction_type', 'amount', 'description', 'created_at']
    list_filter = ['transaction_type', 'created_at']
    search_fields = ['user__username', 'description']
    raw_id_fields = ['user']
    date_hierarchy = 'created_at'

@admin.register(Gift)
class GiftAdmin(admin.ModelAdmin):
    list_display = ['name', 'cost', 'category', 'is_active']
    list_filter = ['category', 'is_active']
    search_fields = ['name']
