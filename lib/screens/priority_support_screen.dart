import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

/// Priority Support screen.
///
/// Honest by design: it does NOT invent a support backend or claim 24/7 human
/// support. It reuses the project's REAL existing resources (Privacy Policy
/// URL, public project page) for help, and shows the signed-in account.
class PrioritySupportScreen extends StatelessWidget {
  const PrioritySupportScreen({super.key});

  static const String _privacyPolicyUrl = 'https://factonezy.github.io/guardpost/';
  static const String _projectUrl = 'https://github.com/factonezy/guardpost';

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link open nahi ho saka: $url'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountEmail = AuthService().currentUser?.email;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Priority Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 56, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  const Text('Premium Priority Support',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    accountEmail != null
                        ? 'For account: $accountEmail'
                        : 'Sign in to see your account',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('What this includes',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            _infoRow(
              Icons.star,
              'Priority handling',
              'Premium members get priority handling on support requests.',
            ),
            _infoRow(
              Icons.info,
              'Honest availability',
              'This build does not yet include a live support inbox or 24/7 '
              'human chat. We are not claiming round-the-clock human support '
              'that does not exist.',
            ),
            const SizedBox(height: 16),
            const Text('Get help',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ListTile(
              leading:
                  const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
              title: const Text('Privacy Policy',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Read how your data is handled',
                  style: TextStyle(color: AppTheme.textSecondary)),
              trailing:
                  const Icon(Icons.open_in_new, color: AppTheme.textSecondary),
              onTap: () => _openUrl(context, _privacyPolicyUrl),
            ),
            ListTile(
              leading: const Icon(Icons.code, color: AppTheme.primaryColor),
              title: const Text('Project & Issues',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('View the open-source project page',
                  style: TextStyle(color: AppTheme.textSecondary)),
              trailing:
                  const Icon(Icons.open_in_new, color: AppTheme.textSecondary),
              onTap: () => _openUrl(context, _projectUrl),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Text(
                'When a direct support channel is added, it will be announced '
                'here. Until then, the resources above are the official ways '
                'to reach the GuardPost project.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
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
