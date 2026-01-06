import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'api_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _fcm;
  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    try {
      // Initialize Firebase Core
      try {
        await Firebase.initializeApp();
        if (kDebugMode) {
          print('🔥 Firebase initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase initialization failed (check google-services.json): $e');
        }
        return; // Stop initialization if Firebase Core fails
      }

      // Initialize Firebase Messaging after Firebase Core
      _fcm = FirebaseMessaging.instance;

      // Request permissions
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        print('🔔 User granted permission: ${settings.authorizationStatus}');
      }

      // Get FCM token
      String? token = await _fcm!.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('🔑 FCM Token: $token');
        }
        // Send token to backend
        await _sendTokenToBackend(token);
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('📩 Received foreground message: ${message.notification?.title}');
        }
        _notificationService.showLocalNotification(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? '',
          payload: message.data['postId'],
        );
      });

      // Handle message open app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('📬 App opened from notification: ${message.data}');
        }
        _handleNotificationNavigation(message.data);
      });

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase: $e');
      }
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print('Background message: ${message.messageId}');
    }
  }

  Future<String?> getToken() async {
    return await _fcm?.getToken();
  }

  Future<void> deleteToken() async {
    await _fcm?.deleteToken();
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/notifications/api/push-tokens/register/',
        data: {
          'token': token,
          'device_type': 'android', // You might want to detect platform
          'device_id': '', // You might want to generate a unique device ID
        },
      );
      if (kDebugMode) {
        print('✅ FCM Token sent to backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send FCM token to backend: $e');
      }
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle navigation based on notification data
    // This is a simple implementation - you might want to use a navigation service
    final postId = data['postId'];
    final userId = data['userId'];
    final conversationId = data['conversationId'];

    if (postId != null) {
      // Navigate to post detail
      if (kDebugMode) {
        print('🧭 Navigating to post: $postId');
      }
      // You would implement navigation here, e.g.:
      // navigatorKey.currentState?.pushNamed('/post/$postId');
    } else if (userId != null) {
      // Navigate to user profile
      if (kDebugMode) {
        print('🧭 Navigating to user profile: $userId');
      }
    } else if (conversationId != null) {
      // Navigate to chat
      if (kDebugMode) {
        print('🧭 Navigating to chat: $conversationId');
      }
    }
  }
}
