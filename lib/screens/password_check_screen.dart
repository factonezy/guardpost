import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/breach_check_service.dart';

class PasswordCheckScreen extends StatefulWidget {
  const PasswordCheckScreen({super.key});

  @override
  State<PasswordCheckScreen> createState() => _PasswordCheckScreenState();
}

class _PasswordCheckScreenState extends State<PasswordCheckScreen> {
  final _passwordController = TextEditingController();
  final _breachService = BreachCheckService();
  bool _obscurePassword = true;
  PasswordStrengthResult? _result;
  bool _hasChecked = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPassword() {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    final result = _breachService.checkPasswordStrength(password);
    setState(() {
      _result = result;
      _hasChecked = true;
    });
  }

  Color _getColor(ColorClass color) {
    switch (color) {
      case ColorClass.red:
        return AppTheme.errorColor;
      case ColorClass.orange:
        return AppTheme.warningColor;
      case ColorClass.yellow:
        return Colors.amber;
      case ColorClass.green:
        return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Password Checker')),
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
                        color: AppTheme.warningColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.password_outlined, size: 48, color: AppTheme.warningColor),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Password Strength Checker',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apne password ki strength check karein',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      onChanged: (_) => _checkPassword(),
                    ),
                    if (_hasChecked && _result != null) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _result!.score / 100,
                          backgroundColor: AppTheme.cardColor,
                          valueColor: AlwaysStoppedAnimation(_getColor(_result!.color)),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Strength: ${_result!.strength}',
                            style: TextStyle(
                              color: _getColor(_result!.color),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${_result!.score}/100',
                            style: TextStyle(
                              color: _getColor(_result!.color),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_hasChecked && _result != null && _result!.feedback.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suggestions to improve:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._result!.feedback.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_forward, size: 16, color: AppTheme.warningColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(f, style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: AppTheme.secondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: 12+ characters with mix of letters, numbers & symbols use karein',
                        style: TextStyle(color: AppTheme.secondaryColor, fontSize: 13),
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
