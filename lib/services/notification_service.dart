import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
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
