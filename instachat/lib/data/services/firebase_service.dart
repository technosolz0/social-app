import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _fcm;
  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    try {
      // Initialize Firebase Core
      await Firebase.initializeApp();

      if (kDebugMode) {
        print('🔥 Firebase initialized successfully');
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
        // TODO: Send token to backend
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
        // TODO: Navigate to specific screen based on message data
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
}
