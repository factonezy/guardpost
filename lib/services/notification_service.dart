import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Use a real, existing notification drawable. Do NOT let a missing
      // resource or plugin failure crash the whole app at startup.
      const androidSettings = AndroidInitializationSettings('ic_notification');
      const initSettings = InitializationSettings(android: androidSettings);
      await _notifications.initialize(initSettings);
      // Android 13+ requires explicit POST_NOTIFICATIONS permission.
      await requestPermission();
    } catch (e) {
      debugPrint('NotificationService.initialize failed (non-fatal): $e');
    }
  }

  /// Request notification permission (needed on Android 13+ / API 33+).
  static Future<void> requestPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.notification.request();
    }
  }

  static Future<void> sendBreachAlert({
    required String email,
    required String breachName,
    required String breachDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'breach_alerts',
      'Breach Alerts',
      channelDescription: 'Real-time breach alerts for your accounts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🚨 Breach Alert: $breachName',
      'Your email ($email) was found in a breach from $breachDate!',
      details,
    );
  }

  static Future<void> sendWeeklyDigest({
    required String email,
    required int breachCount,
    required int newThreats,
  }) async {
    if (breachCount == 0 && newThreats == 0) return;

    const androidDetails = AndroidNotificationDetails(
      'weekly_digest',
      'Weekly Security Digest',
      channelDescription: 'Weekly summary of your security status',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '📊 Weekly Security Digest',
      '$breachCount new breaches, $newThreats new threats detected.',
      details,
    );
  }
}
