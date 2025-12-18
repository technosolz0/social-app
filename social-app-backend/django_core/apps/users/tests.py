from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status

User = get_user_model()

class UserModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

    def test_user_creation(self):
        """Test user is created correctly"""
        self.assertEqual(self.user.username, 'testuser')
        self.assertTrue(self.user.check_password('testpass123'))

    def test_user_profile_created(self):
        """Test user profile is auto-created"""
        self.assertTrue(hasattr(self.user, 'profile'))

class UserAPITest(APITestCase):
    def test_user_registration(self):
        """Test user registration endpoint"""
        data = {
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'newpass123'
        }
        response = self.client.post('/api/v1/users/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_user_login(self):
        """Test user login endpoint"""
        # Create user
        User.objects.create_user(
            username='loginuser',
            email='login@example.com',
            password='loginpass123'
        )

        # Login
        data = {
            'email': 'login@example.com',
            'password': 'loginpass123'
        }
        response = self.client.post('/api/v1/users/login/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
