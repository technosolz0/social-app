from rest_framework import serializers
from .models import Conversation, Message
from apps.users.serializers import UserSerializer

class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'conversation', 'sender', 'message_type', 'content',
                  'media_url', 'is_read', 'reply_to', 'created_at', 'updated_at']
        read_only_fields = ['id', 'is_read', 'created_at', 'updated_at']

class ConversationSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'conversation_type', 'name', 'avatar', 'participants',
                  'last_message', 'unread_count', 'created_at', 'updated_at']

    def get_last_message(self, obj):
        last_msg = obj.messages.last()
        if last_msg:
            return MessageSerializer(last_msg).data
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.messages.exclude(
                read_by=request.user
            ).exclude(sender=request.user).count()
        return 0
