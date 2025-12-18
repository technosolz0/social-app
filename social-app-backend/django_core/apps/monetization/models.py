
from django.db import models
import uuid
from ..users.models import CustomUser

class UserWallet(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='wallet')
    coins_balance = models.IntegerField(default=0)
    total_earned = models.IntegerField(default=0)
    total_spent = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_wallets'

class Transaction(models.Model):
    TRANSACTION_TYPES = [
        ('purchase', 'Purchase'),
        ('gift_sent', 'Gift Sent'),
        ('gift_received', 'Gift Received'),
        ('earning', 'Earning'),
        ('withdrawal', 'Withdrawal'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)
    amount = models.IntegerField()
    description = models.TextField()
    metadata = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'transactions'
        ordering = ['-created_at']

class Gift(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    icon_url = models.URLField()
    cost = models.IntegerField()
    category = models.CharField(max_length=50)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gifts'
