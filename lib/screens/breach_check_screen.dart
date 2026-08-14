import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/breach_check_service.dart';
import '../services/notification_service.dart';
import '../services/scan_history_service.dart';

class BreachCheckScreen extends StatefulWidget {
  const BreachCheckScreen({super.key});

  @override
  State<BreachCheckScreen> createState() => _BreachCheckScreenState();
}

class _BreachCheckScreenState extends State<BreachCheckScreen> {
  final _emailController = TextEditingController();
  final _breachService = BreachCheckService();
  bool _isLoading = false;
  BreachResult? _result;
  bool _hasChecked = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkBreach() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valid email daalein'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _breachService.checkEmail(email);
      // If the email is in a breach, push a local notification alert.
      if (result.status == BreachStatus.breached && result.breaches.isNotEmpty) {
        final breach = result.breaches.first;
        await NotificationService.sendBreachAlert(
          email: email,
          breachName: breach.name,
          breachDate: breach.breachDate,
        );
      }
      setState(() {
        _result = result;
        _hasChecked = true;
        _isLoading = false;
      });
      // Persist the REAL result so Full History shows genuine data only.
      await ScanHistoryService.addEntry(ScanHistoryEntry(
        type: 'breach',
        email: email,
        status: result.status.name,
        breachCount: result.breachCount,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Breach Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.email_outlined, size: 48, color: AppTheme.errorColor),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Email Breach Check',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check karein ki aapka email kisi data breach mein leak hua ya nahi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _checkBreach,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('Check Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_hasChecked && _result != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result!;
    final status = result.status;

    // Determine presentation based on the precise status.
    late final IconData icon;
    late final Color color;
    late final String title;
    late final String subtitle;
    late final bool showBreaches;

    switch (status) {
      case BreachStatus.breached:
        icon = Icons.warning_amber;
        color = AppTheme.errorColor;
        title = 'Breach Found!';
        subtitle = '${result.breachCount} breach(es) detected';
        showBreaches = true;
      case BreachStatus.safe:
        icon = Icons.check_circle;
        color = AppTheme.successColor;
        title = 'No Breach Found';
        subtitle = 'Your email seems safe';
        showBreaches = false;
      case BreachStatus.configMissing:
        icon = Icons.cloud_off;
        color = AppTheme.warningColor;
        title = 'Unavailable';
        subtitle = result.message ?? 'Breach check is currently unavailable.';
        showBreaches = false;
      case BreachStatus.authError:
        icon = Icons.key_off;
        color = AppTheme.warningColor;
        title = 'API Error';
        subtitle = result.message ?? 'Authentication error.';
        showBreaches = false;
      case BreachStatus.networkError:
        icon = Icons.wifi_off;
        color = AppTheme.warningColor;
        title = 'Network Error';
        subtitle = result.message ?? 'Could not reach the breach service.';
        showBreaches = false;
      case BreachStatus.unexpected:
        icon = Icons.error_outline;
        color = AppTheme.warningColor;
        title = 'Service Error';
        subtitle = result.message ?? 'Unexpected response from the server.';
        showBreaches = false;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showBreaches) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderColor),
              const SizedBox(height: 8),
              ..._result!.breaches.map((breach) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          breach.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (breach.breachDate.isNotEmpty)
                      Text('Date: ${breach.breachDate}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    if (breach.dataClasses.isNotEmpty)
                      Text('Data leaked: ${breach.dataClasses.join(", ")}', style: TextStyle(color: AppTheme.warningColor, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      breach.description.replaceAll(RegExp(r'<[^>]*>'), ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppTheme.warningColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Involved emails ka password turant change karein!',
                        style: TextStyle(color: AppTheme.warningColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
