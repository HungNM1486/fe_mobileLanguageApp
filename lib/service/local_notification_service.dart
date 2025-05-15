import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/notification_model.dart';

class LocalNotificationService {
  // Singleton instance
  static final LocalNotificationService _instance =
      LocalNotificationService._();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize notification channels and permissions
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings with requested permissions
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // handle older iOS notification callback (iOS < 10)
        debugPrint('Received iOS notification: $title');
      },
    );

    // Combined initialization settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click
        _handleNotificationClick(response.payload);
      },
    );

    // Create notification channels for Android
    await _setupNotificationChannels();

    // Request permissions on iOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    _isInitialized = true;
  }

  // Set up notification channels for Android
  Future<void> _setupNotificationChannels() async {
    // Main channel for most notifications
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel',
          'Important Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.blue,
        ));

    // Achievement notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'achievement_channel',
          'Achievement Notifications',
          description: 'This channel is used for achievement notifications.',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.amber,
        ));

    // Comment notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'comment_channel',
          'Comment Notifications',
          description: 'This channel is used for comment notifications.',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.green,
        ));

    // Reminder notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'reminder_channel',
          'Reminder Notifications',
          description: 'This channel is used for reminder notifications.',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.blue,
        ));
  }

  // Handle notification click
  void _handleNotificationClick(String? payload) {
    if (payload != null) {
      try {
        final data = json.decode(payload);
        debugPrint('Notification clicked: $data');

        // Here you would typically navigate to the appropriate screen
        // This requires a navigation key or a BuildContext, which we don't have in this service
        // You could use a global navigation key or events to handle this
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Show a notification immediately
  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) await initialize();

    // Select the appropriate channel based on notification type
    String channelId;
    switch (notification.type) {
      case 'achievement':
        channelId = 'achievement_channel';
        break;
      case 'comment':
        channelId = 'comment_channel';
        break;
      case 'reminder':
        channelId = 'reminder_channel';
        break;
      case 'system':
      default:
        channelId = 'high_importance_channel';
        break;
    }

    // Prepare the notification details
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      color: _getNotificationColor(notification.type),
      icon: '@mipmap/ic_launcher',
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Create a payload with the notification data
    final payload = json.encode({
      'id': notification.id,
      'type': notification.type,
      'data': notification.data,
    });

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      notification.id ?? 0,
      notification.title,
      notification.content,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String type = 'system',
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) await initialize();

    // Select the appropriate channel based on notification type
    String channelId;
    switch (type) {
      case 'achievement':
        channelId = 'achievement_channel';
        break;
      case 'comment':
        channelId = 'comment_channel';
        break;
      case 'reminder':
        channelId = 'reminder_channel';
        break;
      case 'system':
      default:
        channelId = 'high_importance_channel';
        break;
    }

    // Prepare notification details
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      color: _getNotificationColor(type),
      icon: '@mipmap/ic_launcher',
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Create a payload with the notification data
    final payload = json.encode({
      'id': id,
      'type': type,
      'data': data,
    });

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Helper to get channel name
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'achievement_channel':
        return 'Achievement Notifications';
      case 'comment_channel':
        return 'Comment Notifications';
      case 'reminder_channel':
        return 'Reminder Notifications';
      case 'high_importance_channel':
      default:
        return 'Important Notifications';
    }
  }

  // Helper to get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'achievement_channel':
        return 'This channel is used for achievement notifications.';
      case 'comment_channel':
        return 'This channel is used for comment notifications.';
      case 'reminder_channel':
        return 'This channel is used for reminder notifications.';
      case 'high_importance_channel':
      default:
        return 'This channel is used for important notifications.';
    }
  }

  // Helper to get notification color based on type
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'achievement':
        return Colors.amber;
      case 'comment':
        return Colors.green;
      case 'reminder':
        return Colors.blue;
      case 'system':
      default:
        return Colors.purple;
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
