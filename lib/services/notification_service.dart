import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing push notifications via Firebase Cloud Messaging
///
/// Handles FCM token registration, notification permissions, and local
/// notification display.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Initialize the notification service
  ///
  /// Sets up FCM, local notifications, and registers device token.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('Notification permissions granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        developer.log('Provisional notification permissions granted');
      } else {
        developer.log('Notification permissions denied');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and register FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _registerFCMToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_registerFCMToken);

      // Set up foreground notification handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Set up background notification handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      developer.log('Notification service initialized');
    } catch (e) {
      developer.log('Failed to initialize notification service', error: e);
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload != null) {
          _handleLocalNotificationTap(details.payload!);
        }
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'luminalink_default',
      'LuminaLink Notifications',
      description: 'Notifications for location alerts and circle updates',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Register FCM token with Firestore
  Future<void> _registerFCMToken(String token) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await _authService.updateFCMToken(token);
      developer.log('FCM token registered: ${token.substring(0, 20)}...');
    } catch (e) {
      developer.log('Failed to register FCM token', error: e);
    }
  }

  // ==========================================================================
  // NOTIFICATION HANDLERS
  // ==========================================================================

  /// Handle foreground notifications
  void _handleForegroundMessage(RemoteMessage message) {
    developer.log('Foreground notification received: ${message.messageId}');

    // Show local notification
    showLocalNotification(
      title: message.notification?.title ?? 'LuminaLink',
      body: message.notification?.body ?? '',
      payload: message.data['payload'] as String?,
    );
  }

  /// Handle notification tap (background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    developer.log('Notification tapped: ${message.messageId}');

    // TODO: Navigate to appropriate screen based on notification type
    final notificationType = message.data['type'] as String?;
    final targetId = message.data['targetId'] as String?;

    if (notificationType == 'place_enter' || notificationType == 'place_exit') {
      // Navigate to circle or map screen
      developer.log('Place notification: $notificationType for $targetId');
    } else if (notificationType == 'circle_invite') {
      // Navigate to circle details
      developer.log('Circle invite notification for $targetId');
    }
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(String payload) {
    developer.log('Local notification tapped with payload: $payload');
    // TODO: Parse payload and navigate
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'luminalink_default',
      'LuminaLink Notifications',
      channelDescription: 'Notifications for location alerts and circle updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ==========================================================================
  // PLACE NOTIFICATIONS
  // ==========================================================================

  /// Send a place entry notification to circle members
  Future<void> sendPlaceEntryNotification({
    required String placeId,
    required String placeName,
    required String userId,
    required String userName,
    required String circleId,
  }) async {
    try {
      // Create notification document
      await _firestore.collection('notifications').add({
        'type': 'place_enter',
        'placeId': placeId,
        'placeName': placeName,
        'userId': userId,
        'userName': userName,
        'circleId': circleId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      developer.log('Place entry notification sent: $userName entered $placeName');
    } catch (e) {
      developer.log('Failed to send place entry notification', error: e);
    }
  }

  /// Send a place exit notification to circle members
  Future<void> sendPlaceExitNotification({
    required String placeId,
    required String placeName,
    required String userId,
    required String userName,
    required String circleId,
  }) async {
    try {
      // Create notification document
      await _firestore.collection('notifications').add({
        'type': 'place_exit',
        'placeId': placeId,
        'placeName': placeName,
        'userId': userId,
        'userName': userName,
        'circleId': circleId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      developer.log('Place exit notification sent: $userName left $placeName');
    } catch (e) {
      developer.log('Failed to send place exit notification', error: e);
    }
  }

  // ==========================================================================
  // PERMISSIONS
  // ==========================================================================

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ==========================================================================
  // TOKEN MANAGEMENT
  // ==========================================================================

  /// Get the current FCM token
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  /// Delete the FCM token (call on logout)
  Future<void> deleteFCMToken() async {
    try {
      await _messaging.deleteToken();
      developer.log('FCM token deleted');
    } catch (e) {
      developer.log('Failed to delete FCM token', error: e);
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Background notification received: ${message.messageId}');
  // Handle background notification
}
