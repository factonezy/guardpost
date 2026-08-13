import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/breach_check_screen.dart';
import 'screens/password_check_screen.dart';
import 'screens/phishing_scan_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/security_score_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GuardPostApp());
}

class GuardPostApp extends StatelessWidget {
  const GuardPostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardPost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/breach-check': (context) => const BreachCheckScreen(),
        '/password-check': (context) => const PasswordCheckScreen(),
        '/phishing-scan': (context) => const PhishingScanScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/security-score': (context) => const SecurityScoreScreen(),
      },
    );
  }
}
