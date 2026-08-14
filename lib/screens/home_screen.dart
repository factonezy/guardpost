import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../services/notification_service.dart';
import '../models/security_scan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String privacyPolicyUrl = 'https://factonezy.github.io/guardpost/';
  final _authService = AuthService();
  final _subscriptionService = SubscriptionService();
  int _currentNavIndex = 0;
  String? _userEmail;
  SecurityScanResult? _lastScan;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _subscriptionService.initialize();
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('security_score');
    final emailScore = prefs.getInt('email_breach_score');
    final passwordScore = prefs.getInt('password_score');
    final phishingScore = prefs.getInt('phishing_score');

    if (score != null) {
      _lastScan = SecurityScanResult(
        emailBreachScore: emailScore ?? 0,
        passwordScore: passwordScore ?? 0,
        phishingScore: phishingScore ?? 0,
      );
    }
    setState(() {
      _userEmail = _authService.currentUser?.email ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('GuardPost'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _onNotificationBell,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'profile') {
                setState(() => _currentNavIndex = 2);
              } else if (value == 'settings') {
                _showSettings(context);
              } else if (value == 'logout') {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildToolsTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Score Card
          Card(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Security Score',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (_subscriptionService.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 14, color: AppTheme.primaryColor),
                              SizedBox(width: 4),
                              Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: _lastScan != null ? _lastScan!.totalScore / 100 : 0,
                          strokeWidth: 12,
                          backgroundColor: AppTheme.cardColor,
                          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _lastScan?.grade ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _lastScan?.label ?? 'Scan karne ke liye\nniche tools use karo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildQuickActionCard(
                icon: Icons.email_outlined,
                title: 'Breach Check',
                subtitle: 'Check email leaks',
                color: AppTheme.errorColor,
                onTap: () => Navigator.pushNamed(context, '/breach-check'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickActionCard(
                icon: Icons.password_outlined,
                title: 'Password',
                subtitle: 'Check strength',
                color: AppTheme.warningColor,
                onTap: () => Navigator.pushNamed(context, '/password-check'),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildQuickActionCard(
                icon: Icons.link_off,
                title: 'Phishing Scan',
                subtitle: 'Scan suspicious links',
                color: AppTheme.secondaryColor,
                onTap: () => Navigator.pushNamed(context, '/phishing-scan'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickActionCard(
                icon: Icons.shield_outlined,
                title: 'Full Scan',
                subtitle: 'Complete security check',
                color: AppTheme.primaryColor,
                onTap: () => _runFullScan(),
              )),
            ],
          ),

          const SizedBox(height: 24),
          // Recent activity
          Text(
            'Security Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '🔐', 'Strong Passwords',
            'Har account ke liye unique password use karein. Password manager use karein.',
          ),
          const SizedBox(height: 8),
          _buildTipCard(
            '📧', 'Email Vigilance',
            'Anjaan emails mein links click na karein. Sender ko verify karein.',
          ),
          const SizedBox(height: 8),
          _buildTipCard(
            '🔑', '2FA Enable Karein',
            'Jahan bhi possible ho, Two-Factor Authentication on karein.',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String emoji, String title, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
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

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Tools',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            icon: Icons.email_outlined,
            title: 'Email Breach Check',
            description: 'Pata karein ki aapka email kisi data breach mein leak hua hai ya nahi',
            color: AppTheme.errorColor,
            onTap: () => Navigator.pushNamed(context, '/breach-check'),
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            icon: Icons.password_outlined,
            title: 'Password Strength Checker',
            description: 'Apne password ki strength test karein aur suggestions payein',
            color: AppTheme.warningColor,
            onTap: () => Navigator.pushNamed(context, '/password-check'),
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            icon: Icons.link_off,
            title: 'Phishing Link Scanner',
            description: 'Koi bhi link safe hai ya scam, check karein',
            color: AppTheme.secondaryColor,
            onTap: () => Navigator.pushNamed(context, '/phishing-scan'),
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            icon: Icons.shield_outlined,
            title: 'Security Score',
            description: 'Apni overall digital security ka score dekhein',
            color: AppTheme.primaryColor,
            onTap: () => Navigator.pushNamed(context, '/security-score'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardColor,
            ),
            child: const Icon(Icons.person, size: 40, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            _userEmail ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _subscriptionService.isPremium
                  ? AppTheme.primaryColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _subscriptionService.isPremium
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
            ),
            child: Text(
              _subscriptionService.isPremium ? 'PREMIUM' : 'FREE',
              style: TextStyle(
                color: _subscriptionService.isPremium
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileOption(Icons.stars_outlined, 'Go Premium', () {
                    Navigator.pushNamed(context, '/subscription');
                  }),
                  const Divider(color: AppTheme.borderColor),
                  _buildProfileOption(Icons.info_outline, 'About GuardPost', () => _showAbout(context)),
                  const Divider(color: AppTheme.borderColor),
                  _buildProfileOption(Icons.description_outlined, 'Privacy Policy', () => _launchUrl(privacyPolicyUrl)),
                  const Divider(color: AppTheme.borderColor),
                  _buildProfileOption(Icons.logout, 'Logout', () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link open nahi ho saka: $url'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('About GuardPost', style: TextStyle(color: Colors.white)),
        content: const Text(
          'GuardPost - Personal Digital Security Control Center.\n\n'
          'Apni email, password aur links ko breaches aur scams se bachayein.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onNotificationBell() {
    // Use the real notification service: request permission, then show the
    // (currently empty) alert list. No await before showDialog, so we never
    // touch BuildContext across an async gap.
    NotificationService.requestPermission();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        content: const Text(
          'No alerts yet. When we detect a breach for your email, you\'ll get '
          'an instant alert here.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    final status = await Permission.notification.status;
    final enabled = status.isGranted;
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined, color: Colors.white70),
              title: const Text('Breach Alerts', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                enabled ? 'Enabled' : 'Disabled',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: TextButton(
                onPressed: () {
                  // Fire-and-forget: request permission then close the dialog.
                  Permission.notification.request();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Change'),
              ),
            ),
            const Divider(color: AppTheme.borderColor),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showAbout(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined, color: Colors.white70),
              title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(ctx).pop();
                _launchUrl(privacyPolicyUrl);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _runFullScan() async {
    if (!mounted) return;
    Navigator.pushNamed(context, '/security-score');
  }
}
