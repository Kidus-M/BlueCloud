import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Initialize notifications
  Future<void> initialize(String userId) async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestoreService.updateFcmToken(userId, token);
        debugPrint('FCM Token: $token');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _firestoreService.updateFcmToken(userId, newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.notification?.title}');
        // Handle foreground notification
        _handleMessage(message);
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened app: ${message.notification?.title}');
        _handleMessageTap(message);
      });
    } else {
      debugPrint('User declined notification permission');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToReports() async {
    await _messaging.subscribeToTopic('new_reports');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromReports() async {
    await _messaging.unsubscribeFromTopic('new_reports');
  }

  // Handle incoming message
  void _handleMessage(RemoteMessage message) {
    debugPrint('Message data: ${message.data}');
  }

  // Handle message tap
  void _handleMessageTap(RemoteMessage message) {
    debugPrint('Message tapped: ${message.data}');
  }
}

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}
