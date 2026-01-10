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
      // Initialize Firebase Core with explicit options
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAfFLUysoo1E-5yU2FYfGyV347TdymUM2Y',
            appId: '1:41446007568:android:62ff587cb6d8bab89fbb95',
            messagingSenderId: '41446007568',
            projectId: 'instachat-6cea0',
            storageBucket: 'instachat-6cea0.firebasestorage.app',
            databaseURL: 'https://instachat-6cea0-default-rtdb.firebaseio.com',
          ),
        );
        if (kDebugMode) {
          print('🔥 Firebase initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase initialization failed: $e');
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
      await apiService.registerPushToken(
        token: token,
        deviceType: 'android', // You might want to detect platform
        deviceId: '', // You might want to generate a unique device ID
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
