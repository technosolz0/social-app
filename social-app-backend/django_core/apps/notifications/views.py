from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import PushToken

class PushTokenViewSet(viewsets.ModelViewSet):
    queryset = PushToken.objects.all()
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return PushToken.objects.filter(user=self.request.user, is_active=True)

    @action(detail=False, methods=['post'])
    def register(self, request):
        """Register a device push token"""
        token = request.data.get('token')
        device_type = request.data.get('device_type', 'android')
        device_id = request.data.get('device_id', '')

        if not token:
            return Response(
                {'error': 'Token is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create or update push token
        push_token, created = PushToken.objects.update_or_create(
            user=request.user,
            device_id=device_id,
            defaults={
                'token': token,
                'device_type': device_type,
                'is_active': True,
            }
        )

        return Response({
            'message': 'Token registered successfully',
            'created': created,
        })

    @action(detail=False, methods=['post'])
    def unregister(self, request):
        """Unregister a device push token"""
        device_id = request.data.get('device_id')

        if device_id:
            PushToken.objects.filter(
                user=request.user,
                device_id=device_id
            ).update(is_active=False)
        else:
            # Unregister all tokens for user
            PushToken.objects.filter(user=request.user).update(is_active=False)

        return Response({'message': 'Token unregistered successfully'})
