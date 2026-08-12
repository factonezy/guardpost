class SecurityScanResult {
  final int emailBreachScore;
  final int passwordScore;
  final int phishingScore;
  final int totalScore;

  SecurityScanResult({
    this.emailBreachScore = 0,
    this.passwordScore = 0,
    this.phishingScore = 0,
  }) : totalScore = ((emailBreachScore + passwordScore + phishingScore) / 3).round();

  String get grade {
    if (totalScore >= 85) return 'A';
    if (totalScore >= 70) return 'B';
    if (totalScore >= 50) return 'C';
    if (totalScore >= 30) return 'D';
    return 'F';
  }

  String get label {
    if (totalScore >= 85) return 'Excellent!';
    if (totalScore >= 70) return 'Good';
    if (totalScore >= 50) return 'Average';
    if (totalScore >= 30) return 'Needs Work';
    return 'Critical!';
  }

  List<String> get recommendations {
    final recs = <String>[];
    if (emailBreachScore < 70) {
      recs.add('Apna email breach check karein aur passwords change karein');
    }
    if (passwordScore < 70) {
      recs.add('Mazboot password set karein (8+ chars, special chars, numbers)');
    }
    if (phishingScore < 70) {
      recs.add('Phishing links se bachne ke liye cautious rahein');
    }
    return recs;
  }
}
