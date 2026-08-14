import 'package:guardpost/api_keys.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BreachCheckService {
  // Have I Been Pwned API v3
  static const String _hibpBaseUrl = 'https://haveibeenpwned.com/api/v3';
  static const String _hibpUserAgent = 'GuardPost-App-1.0';

  /// Check if email has been in breaches using HIBP (k-anonymity model)
  Future<BreachResult> checkEmail(String email) async {
    // If the API key is missing we cannot perform a real check.
    // Never report this as "safe" — surface the configuration issue instead.
    if (ApiKeys.hibpApiKey.isEmpty) {
      return BreachResult(
        status: BreachStatus.configMissing,
        isBreached: false,
        breachCount: 0,
        breaches: [],
        message:
            'Breach check is currently unavailable. API configuration is required.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$_hibpBaseUrl/breachedaccount/${Uri.encodeComponent(email)}'),
        headers: {
          'hibp-api-key': ApiKeys.hibpApiKey,
          'User-Agent': _hibpUserAgent,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> breaches = json.decode(response.body);
        return BreachResult(
          status: BreachStatus.breached,
          isBreached: true,
          breachCount: breaches.length,
          breaches: breaches.map((b) => BreachInfo(
            name: b['Name'] ?? 'Unknown',
            domain: b['Domain'] ?? '',
            breachDate: b['BreachDate'] ?? '',
            description: b['Description'] ?? '',
            dataClasses: List<String>.from(b['DataClasses'] ?? []),
            pwnCount: b['PwnCount'] ?? 0,
            isVerified: b['IsVerified'] ?? false,
            isSpamList: b['IsSpamList'] ?? false,
          )).toList(),
        );
      } else if (response.statusCode == 404) {
        // HIBP returns 404 specifically to mean "not found in any breach".
        return BreachResult(
          status: BreachStatus.safe,
          isBreached: false,
          breachCount: 0,
          breaches: [],
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Authentication failure must NOT be treated as "no breach".
        return BreachResult(
          status: BreachStatus.authError,
          isBreached: false,
          breachCount: 0,
          breaches: [],
          message:
              'Breach check failed: API key authentication error (${response.statusCode}).',
        );
      } else {
        // Any other status (rate limit, server error, etc.) is NOT "safe".
        return BreachResult(
          status: BreachStatus.unexpected,
          isBreached: false,
          breachCount: 0,
          breaches: [],
          message:
              'Breach check failed: unexpected server response (${response.statusCode}).',
        );
      }
    } catch (e) {
      // A network/parse failure must NOT be reported as "no breach found".
      return BreachResult(
        status: BreachStatus.networkError,
        isBreached: false,
        breachCount: 0,
        breaches: [],
        message: 'Breach check failed: network error. Please try again.',
      );
    }
  }

  /// Check password strength
  PasswordStrengthResult checkPasswordStrength(String password) {
    int score = 0;
    final feedback = <String>[];

    if (password.length >= 8) {
      score += 25;
    } else {
      feedback.add('Password kam se kam 8 characters ka hona chahiye');
    }
    if (password.length >= 12) {
      score += 10;
    }

    if (password.contains(RegExp(r'[a-z]'))) {
      score += 15;
    } else {
      feedback.add('Ek lowercase letter hona chahiye');
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 15;
    } else {
      feedback.add('Ek uppercase letter hona chahiye');
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      score += 15;
    } else {
      feedback.add('Ek digit hona chahiye');
    }

    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      score += 20;
    } else {
      feedback.add('Ek special character hona chahiye (!@#\$%^&*)');
    }

    String strength;
    ColorClass color;
    if (score >= 85) {
      strength = 'Very Strong';
      color = ColorClass.green;
    } else if (score >= 65) {
      strength = 'Strong';
      color = ColorClass.green;
    } else if (score >= 45) {
      strength = 'Medium';
      color = ColorClass.yellow;
    } else if (score >= 25) {
      strength = 'Weak';
      color = ColorClass.orange;
    } else {
      strength = 'Very Weak';
      color = ColorClass.red;
    }

    return PasswordStrengthResult(
      score: score,
      strength: strength,
      feedback: feedback,
      color: color,
    );
  }
}

enum BreachStatus {
  breached,
  safe,
  configMissing,
  authError,
  networkError,
  unexpected,
}

class BreachResult {
  final BreachStatus status;
  final bool isBreached;
  final int breachCount;
  final List<BreachInfo> breaches;
  final String? message;

  BreachResult({
    required this.status,
    required this.isBreached,
    required this.breachCount,
    required this.breaches,
    this.message,
  });
}

class BreachInfo {
  final String name;
  final String domain;
  final String breachDate;
  final String description;
  final List<String> dataClasses;
  final int pwnCount;
  final bool isVerified;
  final bool isSpamList;

  BreachInfo({
    required this.name,
    required this.domain,
    required this.breachDate,
    required this.description,
    required this.dataClasses,
    required this.pwnCount,
    required this.isVerified,
    required this.isSpamList,
  });
}

class PasswordStrengthResult {
  final int score;
  final String strength;
  final List<String> feedback;
  final ColorClass color;

  PasswordStrengthResult({
    required this.score,
    required this.strength,
    required this.feedback,
    required this.color,
  });
}

enum ColorClass { red, orange, yellow, green }
