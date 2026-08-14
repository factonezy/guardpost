import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

/// Instant Alerts screen.
///
/// Reuses the SAME real notification machinery as the app's Settings screen
/// (NotificationService + permission_handler). It explains honestly that
/// delivering alerts for NEW breaches requires a backend monitoring service,
/// which is not implemented, so no automatic breach alerts are sent.
class InstantAlertsScreen extends StatefulWidget {
  const InstantAlertsScreen({super.key});

  @override
  State<InstantAlertsScreen> createState() => _InstantAlertsScreenState();
}

class _InstantAlertsScreenState extends State<InstantAlertsScreen> {
  PermissionStatus _status = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await Permission.notification.status;
    if (mounted) setState(() => _status = status);
  }

  Future<void> _request() async {
    // Real permission request — same mechanism the Settings screen uses.
    await NotificationService.requestPermission();
    final status = await Permission.notification.request();
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final granted = _status.isGranted;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Instant Alerts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (granted ? AppTheme.successColor : AppTheme.warningColor)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (granted ? AppTheme.successColor : AppTheme.warningColor)
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    granted ? Icons.notifications_active : Icons.notifications_off,
                    color: granted ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          granted ? 'Notifications Enabled' : 'Notifications Disabled',
                          style: TextStyle(
                              color: granted
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          granted
                              ? 'Your device can receive push notifications.'
                              : 'Enable notifications to receive alerts on this device.',
                          style: TextStyle(
                              color: granted
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('What Instant Alerts do',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'When Instant Alerts are active, GuardPost sends a push '
              'notification the moment a new breach is detected for your email.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.check_circle,
              'Device permission',
              granted
                  ? 'Notification permission is granted on this device.'
                  : 'Notification permission is not granted. Tap below to enable it.',
            ),
            _infoRow(
              Icons.cloud_queue,
              'Backend monitoring required',
              'Actually delivering alerts for NEW breaches requires a backend '
              'service that periodically checks your email against breach '
              'sources. That monitoring backend is not part of this app build '
              'yet, so no automatic breach alerts are sent.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _request,
                icon: const Icon(Icons.notifications),
                label: Text(granted ? 'Re-check Permission' : 'Enable Notifications'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We do not claim instant breach alerts are active without a real '
              'monitoring backend.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
