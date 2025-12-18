import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from datetime import datetime
import uuid

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.conversation_group_name = f'chat_{self.conversation_id}'
        self.user = self.scope['user']

        # Join conversation group
        await self.channel_layer.group_add(
            self.conversation_group_name,
            self.channel_name
        )

        await self.accept()

        # Notify others user joined
        await self.channel_layer.group_send(
            self.conversation_group_name,
            {
                'type': 'user_joined',
                'user_id': str(self.user.id),
                'username': self.user.username,
            }
        )

    async def disconnect(self, close_code):
        # Leave conversation group
        await self.channel_layer.group_discard(
            self.conversation_group_name,
            self.channel_name
        )

        # Notify others user left
        await self.channel_layer.group_send(
            self.conversation_group_name,
            {
                'type': 'user_left',
                'user_id': str(self.user.id),
                'username': self.user.username,
            }
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type', 'message')

        if message_type == 'message':
            await self.handle_message(data)
        elif message_type == 'typing':
            await self.handle_typing(data)
        elif message_type == 'read_receipt':
            await self.handle_read_receipt(data)

    async def handle_message(self, data):
        """Handle new message"""
        content = data.get('content', '')
        media_url = data.get('media_url', '')
        msg_type = data.get('message_type', 'text')
        reply_to = data.get('reply_to')

        # Save message to database
        message = await self.save_message(
            content=content,
            media_url=media_url,
            message_type=msg_type,
            reply_to=reply_to
        )

        # Send message to conversation group
        await self.channel_layer.group_send(
            self.conversation_group_name,
            {
                'type': 'chat_message',
                'message': {
                    'id': str(message.id),
                    'sender_id': str(self.user.id),
                    'sender_username': self.user.username,
                    'sender_avatar': self.user.profile.avatar,
                    'content': content,
                    'media_url': media_url,
                    'message_type': msg_type,
                    'reply_to': reply_to,
                    'created_at': message.created_at.isoformat(),
                }
            }
        )

    async def handle_typing(self, data):
        """Handle typing indicator"""
        is_typing = data.get('is_typing', False)

        await self.update_typing_status(is_typing)

        # Broadcast typing status
        await self.channel_layer.group_send(
            self.conversation_group_name,
            {
                'type': 'typing_indicator',
                'user_id': str(self.user.id),
                'username': self.user.username,
                'is_typing': is_typing,
            }
        )

    async def handle_read_receipt(self, data):
        """Handle read receipt"""
        message_id = data.get('message_id')

        await self.mark_message_read(message_id)

        # Broadcast read receipt
        await self.channel_layer.group_send(
            self.conversation_group_name,
            {
                'type': 'read_receipt',
                'message_id': message_id,
                'user_id': str(self.user.id),
                'read_at': datetime.now().isoformat(),
            }
        )

    # Receive message from conversation group
    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'type': 'message',
            'message': event['message']
        }))

    async def typing_indicator(self, event):
        # Don't send to self
        if event['user_id'] != str(self.user.id):
            await self.send(text_data=json.dumps({
                'type': 'typing',
                'user_id': event['user_id'],
                'username': event['username'],
                'is_typing': event['is_typing'],
            }))

    async def user_joined(self, event):
        await self.send(text_data=json.dumps({
            'type': 'user_joined',
            'user_id': event['user_id'],
            'username': event['username'],
        }))

    async def user_left(self, event):
        await self.send(text_data=json.dumps({
            'type': 'user_left',
            'user_id': event['user_id'],
            'username': event['username'],
        }))

    async def read_receipt(self, event):
        await self.send(text_data=json.dumps({
            'type': 'read_receipt',
            'message_id': event['message_id'],
            'user_id': event['user_id'],
            'read_at': event['read_at'],
        }))

    # Database operations
    @database_sync_to_async
    def save_message(self, content, media_url, message_type, reply_to):
        from .models import Message, Conversation

        conversation = Conversation.objects.get(id=self.conversation_id)
        message = Message.objects.create(
            conversation=conversation,
            sender=self.user,
            content=content,
            media_url=media_url,
            message_type=message_type,
            reply_to_id=reply_to if reply_to else None
        )

        # Update conversation timestamp
        conversation.save()

        return message

    @database_sync_to_async
    def update_typing_status(self, is_typing):
        from .models import TypingStatus, Conversation

        conversation = Conversation.objects.get(id=self.conversation_id)
        TypingStatus.objects.update_or_create(
            conversation=conversation,
            user=self.user,
            defaults={'is_typing': is_typing}
        )

    @database_sync_to_async
    def mark_message_read(self, message_id):
        from .models import Message

        try:
            message = Message.objects.get(id=message_id)
            message.read_by.add(self.user)

            # Mark as read if all participants have read
            conversation = message.conversation
            participant_count = conversation.participants.count()
            read_count = message.read_by.count()

            if read_count >= participant_count - 1:  # Exclude sender
                message.is_read = True
                message.save()
        except Message.DoesNotExist:
            pass
