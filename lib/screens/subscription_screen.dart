import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/subscription_service.dart';

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
            const SizedBox(height: 24),
            // Features
            ..._buildPremiumFeature(Icons.verified, 'Unlimited Breach Checks', 'Daily auto-scan for all your emails'),
            ..._buildPremiumFeature(Icons.dark_mode, 'Dark Web Monitoring', 'Real-time dark web leak detection'),
            ..._buildPremiumFeature(Icons.family_restroom, 'Family Plan', 'Add upto 5 family members'),
            ..._buildPremiumFeature(Icons.notifications_active, 'Instant Alerts', 'Push notification for new breaches'),
            ..._buildPremiumFeature(Icons.history, 'Full History', 'Complete scan history & trend analysis'),
            ..._buildPremiumFeature(Icons.support_agent, 'Priority Support', '24/7 priority customer support'),
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
              onPressed: () => _subscriptionService.restorePurchases(),
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

  List<Widget> _buildPremiumFeature(IconData icon, String title, String subtitle) {
    return [
      Card(
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
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
    final success = await _subscriptionService.startFreeTrial();
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('7-day free trial started! Enjoy Premium 🎉'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}
