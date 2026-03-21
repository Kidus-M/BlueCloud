import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'blue_cloud_reports',
    'Report Notifications',
    description: 'Notifications for new incident reports',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

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

      // Initialize local notifications
      await _initLocalNotifications();

      // Get FCM token
      try {
        final token = await _messaging.getToken();
        if (token != null) {
          await _firestoreService.updateFcmToken(userId, token);
          debugPrint('FCM Token saved');
        }
      } catch (e) {
        debugPrint('FCM token retrieval/save failed (non-fatal): $e');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _firestoreService.updateFcmToken(userId, newToken).catchError((e) {
          debugPrint('FCM token refresh save failed: $e');
        });
      });

      // Handle foreground messages — show as system notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened app: ${message.notification?.title}');
      });
    } else {
      debugPrint('User declined notification permission');
    }
  }

  // Initialize flutter_local_notifications
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);

    // Create the Android notification channel
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }
  }

  // Show a local notification when a message arrives in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1565C0),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Blue Cloud',
      notification.body ?? 'New notification',
      details,
    );
  }

  // Subscribe to topic
  Future<void> subscribeToReports() async {
    try {
      await _messaging.subscribeToTopic('new_reports');
    } catch (e) {
      debugPrint('Failed to subscribe to reports topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromReports() async {
    try {
      await _messaging.unsubscribeFromTopic('new_reports');
    } catch (e) {
      debugPrint('Failed to unsubscribe from reports topic: $e');
    }
  }
}

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}
