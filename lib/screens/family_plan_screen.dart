import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

/// Family Plan information screen.
///
/// Shows the intended "up to 5 family members" concept, but clearly states that
/// member synchronization is NOT available (no backend/database exists) and does
/// not pretend any members are synced.
class FamilyPlanScreen extends StatelessWidget {
  const FamilyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountEmail = AuthService().currentUser?.email;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Family Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.family_restroom, size: 56, color: Colors.black87),
                  const SizedBox(height: 12),
                  const Text('Protect up to 5 family members',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(
                    accountEmail != null ? 'Account: $accountEmail' : 'Account: not signed in',
                    style: TextStyle(
                        fontSize: 13, color: Colors.black87.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.group_add,
              'How it will work',
              'When available, you will be able to invite up to 5 family '
              'members by email. Each member gets the same Premium protection '
              'under one subscription.',
            ),
            _infoRow(
              Icons.sync,
              'Currently not available',
              'Family member synchronization requires a backend database to '
              'store member relationships. That is not implemented in this '
              'build, so no members can be added or synced yet.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.warningColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Family Plan is shown for transparency. It is not active '
                      'and no family members are synchronized.',
                      style: TextStyle(color: AppTheme.warningColor, fontSize: 13),
                    ),
                  ),
                ],
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
