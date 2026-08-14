import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'breach_check_screen.dart';

/// Dark Web Monitoring status screen.
///
/// Honest by design: it clearly states that automatic/real-time monitoring is
/// NOT active (no backend exists) and does not simulate monitoring.
class DarkWebMonitoringScreen extends StatelessWidget {
  const DarkWebMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Dark Web Monitoring')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBanner(),
            const SizedBox(height: 16),
            const Text(
              'What is Dark Web Monitoring?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dark web monitoring continuously scans underground forums and '
              'leak databases for your personal information (emails, passwords, '
              'phone numbers) and alerts you when it appears.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Current status in this app',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            _infoRow(
              Icons.cloud_off,
              'Automatic monitoring is not active',
              'Real-time dark web scanning requires backend monitoring '
              'infrastructure (a server that periodically queries breach '
              'sources on your behalf). That backend is not part of this app '
              'build yet, so nothing is being monitored automatically.',
            ),
            _infoRow(
              Icons.check_circle,
              'Manual check is available now',
              'You can check whether a specific email has already appeared in '
              'known breaches using the Email Breach Check feature below.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BreachCheckScreen()),
                ),
                icon: const Icon(Icons.search),
                label: const Text('Run a Breach Check'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will not claim your email is being monitored unless real '
              'monitoring is implemented.',
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

  Widget _statusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.warningColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Not Active',
                    style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Automatic dark web monitoring is not currently enabled. '
                  'No email is being monitored right now.',
                  style: TextStyle(color: AppTheme.warningColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
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
