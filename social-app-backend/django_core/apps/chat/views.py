from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer

class ConversationViewSet(viewsets.ModelViewSet):
    serializer_class = ConversationSerializer
    permission_classes = [IsAuthenticated]
    queryset = Conversation.objects.none()  # Set default queryset to avoid warnings

    def get_queryset(self):
        return Conversation.objects.filter(
            participants=self.request.user
        ).prefetch_related('participants')

    @action(detail=False, methods=['post'])
    def create_direct_message(self, request):
        """Create or get direct message conversation"""
        other_user_id = request.data.get('user_id')

        # Check if conversation exists
        conversation = Conversation.objects.filter(
            conversation_type='direct',
            participants=request.user
        ).filter(
            participants__id=other_user_id
        ).first()

        if not conversation:
            # Create new conversation
            conversation = Conversation.objects.create(
                conversation_type='direct',
                created_by=request.user
            )
            conversation.participants.add(request.user, other_user_id)

        serializer = ConversationSerializer(conversation, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def create_group(self, request):
        """Create group chat"""
        name = request.data.get('name')
        participant_ids = request.data.get('participant_ids', [])

        conversation = Conversation.objects.create(
            conversation_type='group',
            name=name,
            created_by=request.user
        )

        conversation.participants.add(request.user)
        for user_id in participant_ids:
            conversation.participants.add(user_id)

        serializer = ConversationSerializer(conversation, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class MessageViewSet(viewsets.ModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        conversation_id = self.request.query_params.get('conversation_id')
        if conversation_id:
            return Message.objects.filter(
                conversation_id=conversation_id,
                conversation__participants=self.request.user
            ).select_related('sender__profile')
        return Message.objects.none()

    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark message as read"""
        message = self.get_object()
        message.read_by.add(request.user)

        # Check if all read
        conversation = message.conversation
        participant_count = conversation.participants.count()
        read_count = message.read_by.count()

        if read_count >= participant_count - 1:
            message.is_read = True
            message.save()

        return Response({'status': 'marked as read'})
