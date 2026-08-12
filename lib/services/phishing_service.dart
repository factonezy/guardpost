import 'dart:convert';
import 'package:http/http.dart' as http;

class PhishingScanService {
  static const String _safeBrowsingUrl =
      'https://safebrowsing.googleapis.com/v4/threatMatches:find';

  /// Scan URL for phishing/malware using Google Safe Browsing
  Future<PhishingResult> scanUrl(String url, {String apiKey = ApiKeys.safeBrowsingApiKey}) async {
    try {
      // Add protocol if missing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      final domain = uri.host;

      // First check: Basic heuristics
      final heuristicIssues = _checkHeuristics(domain, url);

      // Second check: Google Safe Browsing API (if key provided)
      List<String> apiThreats = [];
      if (apiKey.isNotEmpty) {
        apiThreats = await _checkSafeBrowsing(url, apiKey);
      }

      // Third check: Check against known phishing indicators
      final reputationIssues = await _checkReputation(domain);

      final allIssues = [
        ...heuristicIssues,
        ...apiThreats,
        ...reputationIssues,
      ];

      final isSafe = allIssues.isEmpty;
      return PhishingResult(
        isSafe: isSafe,
        issues: allIssues,
        score: _calculateScore(allIssues.length, isSafe),
        domain: domain,
      );
    } catch (e) {
      return PhishingResult(
        isSafe: true,
        issues: ['URL scan karne mein error aaya. Link safe maan liya.'],
        score: 100,
        domain: Uri.tryParse(url)?.host ?? 'unknown',
        error: e.toString(),
      );
    }
  }

  List<String> _checkHeuristics(String domain, String fullUrl) {
    final issues = <String>[];
    final lowerUrl = fullUrl.toLowerCase();
    final lowerDomain = domain.toLowerCase();

    // Check for IP address instead of domain
    final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (ipRegex.hasMatch(domain)) {
      issues.add('Ye ek IP address hai, domain nahi. Phishing ho sakti hai.');
    }

    // Check for excessive subdomains
    final parts = domain.split('.');
    if (parts.length > 3) {
      issues.add('Bahut zyada subdomains hain. Suspicious link ho sakta hai.');
    }

    // Check for common phishing keywords
    final phishingKeywords = [
      'login', 'verify', 'secure', 'account', 'update', 'confirm',
      'bank', 'paypal', 'password', 'credential', 'signin', 'auth',
      'security', 'wallet', 'refund', 'support', 'helpdesk',
    ];
    for (final keyword in phishingKeywords) {
      if (lowerUrl.contains(keyword) && !lowerDomain.contains(keyword)) {
        issues.add('Link mein "$keyword" hai jo phishing mein common hai.');
        break;
      }
    }

    // Check for URL shorteners
    final shorteners = ['bit.ly', 'tinyurl', 'shorturl', 't.co', 'ow.ly',
      'is.gd', 'buff.ly', 'tiny.cc', 'lnkd.in', 'rb.gy', 'cutt.ly',
      'shorte.st', 'adf.ly', 'goo.gl'];
    for (final short in shorteners) {
      if (lowerDomain.contains(short)) {
        issues.add('Yeh ek URL shortener hai. Click karne se pehle soch lo.');
        break;
      }
    }

    // Check for HTTP (not HTTPS)
    if (fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      issues.add('Yeh link HTTP use kar raha hai (secure nahi).');
    }

    // Check for suspicious characters
    if (fullUrl.contains('@') || fullUrl.contains('//') && fullUrl.indexOf('//') != fullUrl.indexOf('://') + 2) {
      issues.add('Link mein suspicious characters (@ ya //) hain.');
    }

    return issues;
  }

  Future<List<String>> _checkSafeBrowsing(String url, String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_safeBrowsingUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'client': {
            'clientId': 'guardpost',
            'clientVersion': '1.0.0',
          },
          'threatInfo': {
            'threatTypes': [
              'MALWARE', 'SOCIAL_ENGINEERING',
              'UNWANTED_SOFTWARE', 'POTENTIALLY_HARMFUL_APPLICATION',
            ],
            'platformTypes': ['ANY_PLATFORM'],
            'threatEntryTypes': ['URL'],
            'threatEntries': [{'url': url}],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('matches')) {
          return (data['matches'] as List)
              .map((m) => '${m['threatType']} threat detected!')
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<String>> _checkReputation(String domain) async {
    final issues = <String>[];
    // Basic domain age check - new domains are riskier
    // In production, use WHOIS or VirusTotal API
    return issues;
  }

  int _calculateScore(int issueCount, bool isSafe) {
    if (isSafe) return 95;
    return (100 - (issueCount * 20)).clamp(0, 100);
  }
}

class PhishingResult {
  final bool isSafe;
  final List<String> issues;
  final int score;
  final String domain;
  final String? error;

  PhishingResult({
    required this.isSafe,
    required this.issues,
    required this.score,
    required this.domain,
    this.error,
  });
}
