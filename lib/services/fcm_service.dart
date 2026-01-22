import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling background message: ${message.messageId}');
  await FCMService.instance.handleBackgroundMessage(message);
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  static FCMService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;

  FCMService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLocalNotifications();
      await _requestPermission();
      await _getFCMToken();
      _setupMessageHandlers();

      _isInitialized = true;
      log('FCM Service initialized successfully');
    } catch (e) {
      log('Error initializing FCM: $e');
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('FCM Permission status: ${settings.authorizationStatus}');
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      log('FCM Token: $_fcmToken');

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        log('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _handleInitialMessage();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    log('Background message received: ${message.messageId}');
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    log('Message opened app: ${message.messageId}');
    _handleNotificationNavigation(message.data);
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from terminated state via notification');
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      // Handle navigation based on payload
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle navigation based on notification data
    final type = data['type'];
    final id = data['id'];

    log('Navigation type: $type, id: $id');

    // TODO: Implement navigation logic based on your app structure
    // Example:
    // if (type == 'debt_reminder') {
    //   navigatorKey.currentState?.pushNamed('/debt-detail', arguments: id);
    // }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      log('FCM token deleted');
    } catch (e) {
      log('Error deleting FCM token: $e');
    }
  }
}