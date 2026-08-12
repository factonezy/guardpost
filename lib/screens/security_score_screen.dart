import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/security_scan.dart';
import '../services/breach_check_service.dart';

class SecurityScoreScreen extends StatefulWidget {
  const SecurityScoreScreen({super.key});

  @override
  State<SecurityScoreScreen> createState() => _SecurityScoreScreenState();
}

class _SecurityScoreScreenState extends State<SecurityScoreScreen> {
  final _breachService = BreachCheckService();
  SecurityScanResult? _scanResult;
  bool _isLoading = false;
  bool _emailChecked = false;
  bool _passwordChecked = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('security_score');
    if (score != null) {
      setState(() {
        _scanResult = SecurityScanResult(
          emailBreachScore: prefs.getInt('email_breach_score') ?? 0,
          passwordScore: prefs.getInt('password_score') ?? 0,
          phishingScore: prefs.getInt('phishing_score') ?? 0,
        );
        _emailChecked = prefs.getBool('email_checked') ?? false;
        _passwordChecked = prefs.getBool('password_checked') ?? false;
      });
    }
  }

  Future<void> _runFullScan() async {
    setState(() => _isLoading = true);

    int emailScore = 0;
    int passwordScore = 0;

    // Check email breach
    if (!_emailChecked && _email != null) {
      final result = await _breachService.checkEmail(_email!);
      emailScore = result.isBreached ? 20 : 90;
    } else {
      emailScore = _scanResult?.emailBreachScore ?? 0;
    }

    // Password check (with default)
    final passwordResult = _breachService.checkPasswordStrength('Sample123!@');
    passwordScore = passwordResult.score;

    final result = SecurityScanResult(
      emailBreachScore: emailScore,
      passwordScore: passwordScore,
      phishingScore: 50,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('security_score', result.totalScore);
    await prefs.setInt('email_breach_score', emailScore);
    await prefs.setInt('password_score', passwordScore);
    await prefs.setInt('phishing_score', 50);
    await prefs.setBool('email_checked', _emailChecked || _email != null);
    await prefs.setBool('password_checked', true);

    setState(() {
      _scanResult = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Security Score')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Score Card
            Card(
              child: Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: _scanResult != null ? _scanResult!.totalScore / 100 : 0,
                            strokeWidth: 16,
                            backgroundColor: AppTheme.cardColor,
                            valueColor: AlwaysStoppedAnimation(
                              _getGradeColor(_scanResult?.grade ?? 'N'),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _scanResult?.grade ?? '--',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(_scanResult?.grade ?? 'N'),
                              ),
                            ),
                            Text(
                              _scanResult?.label ?? 'Not Scanned',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _scanResult != null
                          ? '${_scanResult!.totalScore}/100'
                          : 'Tools se scan karke apna score check karein',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Category scores
            if (_scanResult != null) ...[
              _buildCategoryScore(
                'Email Security',
                _scanResult!.emailBreachScore,
                AppTheme.errorColor,
                Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              _buildCategoryScore(
                'Password Strength',
                _scanResult!.passwordScore,
                AppTheme.warningColor,
                Icons.password_outlined,
              ),
              const SizedBox(height: 12),
              _buildCategoryScore(
                'Phishing Awareness',
                _scanResult!.phishingScore,
                AppTheme.secondaryColor,
                Icons.link_off,
              ),
              const SizedBox(height: 24),
              // Recommendations
              if (_scanResult!.recommendations.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppTheme.warningColor),
                            SizedBox(width: 8),
                            Text(
                              'Recommendations',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_scanResult!.recommendations.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: AppTheme.warningColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _scanResult!.recommendations[i],
                                    style: TextStyle(color: AppTheme.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            // Scan button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runFullScan,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Run Complete Scan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScore(String label, int score, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$score',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return AppTheme.successColor;
      case 'B': return AppTheme.primaryColor;
      case 'C': return AppTheme.warningColor;
      case 'D': return Colors.orange;
      case 'F': return AppTheme.errorColor;
      default: return AppTheme.textSecondary;
    }
  }
}
