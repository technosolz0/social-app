from django.urls import path
from .views import UserViewSet

app_name = 'users'

urlpatterns = [
    path('register/', UserViewSet.as_view({'post': 'create'}), name='register'),
    path('login/', UserViewSet.as_view({'post': 'login'}), name='login'),
    path('me/', UserViewSet.as_view({'get': 'me'}), name='me'),
    path('profile/', UserViewSet.as_view({'patch': 'update_profile'}), name='profile'),
]
