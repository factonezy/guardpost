import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/subscription_service.dart';
import 'breach_check_screen.dart';
import 'dark_web_monitoring_screen.dart';
import 'family_plan_screen.dart';
import 'instant_alerts_screen.dart';
import 'scan_history_screen.dart';
import 'priority_support_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Go Premium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Premium header
            Container(
              padding: const EdgeInsets.all(24),
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
                  const Icon(Icons.shield, size: 64, color: Colors.black87),
                  const SizedBox(height: 12),
                  const Text(
                    'GuardPost Premium',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Full security suite for you & your family',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!SubscriptionService.isConfigured)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.warningColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Subscriptions are unavailable. Configure REVENUECAT_API_KEY '
                        'to enable purchases.',
                        style: TextStyle(color: AppTheme.warningColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // Features
            ..._buildPremiumFeature(
              icon: Icons.verified,
              title: 'Unlimited Breach Checks',
              subtitle: 'Run as many email breach checks as you want',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BreachCheckScreen()),
              ),
            ),
            ..._buildPremiumFeature(
              icon: Icons.dark_mode,
              title: 'Dark Web Monitoring',
              subtitle: 'Continuous monitoring (requires setup)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DarkWebMonitoringScreen()),
              ),
            ),
            ..._buildPremiumFeature(
              icon: Icons.family_restroom,
              title: 'Family Plan',
              subtitle: 'Protect up to 5 family members',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyPlanScreen()),
              ),
            ),
            ..._buildPremiumFeature(
              icon: Icons.notifications_active,
              title: 'Instant Alerts',
              subtitle: 'Breach alerts to your device',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InstantAlertsScreen()),
              ),
            ),
            ..._buildPremiumFeature(
              icon: Icons.history,
              title: 'Full History',
              subtitle: 'Your past scan results',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
              ),
            ),
            ..._buildPremiumFeature(
              icon: Icons.support_agent,
              title: 'Priority Support',
              subtitle: 'Premium support (see app for availability)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrioritySupportScreen()),
              ),
            ),
            const SizedBox(height: 24),
            // Pricing cards
            Row(
              children: [
                Expanded(
                  child: _buildPricingCard(
                    'Monthly', '\$2.99', '/mo',
                    'Billed monthly',
                    false,
                    _selectedPlan == 'monthly',
                    () => setState(() => _selectedPlan = 'monthly'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPricingCard(
                    'Yearly', '\$29.99', '/yr',
                    'Save \$6! Best value',
                    true,
                    _selectedPlan == 'yearly',
                    () => setState(() => _selectedPlan = 'yearly'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => _startTrial(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                      )
                    : const Text('Start 7-Day Free Trial', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final restored = await _subscriptionService.restorePurchases();
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      restored
                          ? 'Purchases restored. Premium is active!'
                          : 'No previous purchases found, or restore failed. '
                            'Make sure RevenueCat is configured.',
                    ),
                    backgroundColor:
                        restored ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                );
              },
              child: Text(
                'Restore Purchases',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPremiumFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return [
      Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Semantics(
            button: true,
            label: '$title. $subtitle',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(subtitle,
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildPricingCard(
    String title, String price, String period,
    String subtitle, bool popular, bool selected, VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (popular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('POPULAR', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            Text(title, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(period, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: AppTheme.primaryColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Future<void> _startTrial() async {
    setState(() => _isLoading = true);
    // Use the plan the user selected on this screen (Monthly/Yearly).
    final success = _selectedPlan == 'yearly'
        ? await _subscriptionService.purchaseYearly()
        : await _subscriptionService.purchaseMonthly();
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('7-day free trial started! Enjoy Premium 🎉'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      // No fake success — surface the real failure (e.g. RevenueCat not
      // configured / offering missing) so the user knows to fix setup.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchase could not be completed. Check RevenueCat configuration '
            '($_selectedPlan plan) and try again.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
