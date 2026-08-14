import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores REAL, locally-performed scans so the Scan History screen can show
/// genuine history. No fake entries are ever written here.
class ScanHistoryEntry {
  final String type; // e.g. 'breach'
  final String? email;
  final String status; // human-readable status string (e.g. 'breached')
  final int breachCount;
  final DateTime timestamp;

  const ScanHistoryEntry({
    required this.type,
    this.email,
    required this.status,
    this.breachCount = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'email': email,
        'status': status,
        'breachCount': breachCount,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) => ScanHistoryEntry(
        type: json['type'] as String? ?? 'scan',
        email: json['email'] as String?,
        status: json['status'] as String? ?? 'unknown',
        breachCount: (json['breachCount'] as num?)?.toInt() ?? 0,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );
}

class ScanHistoryService {
  static const String _key = 'scan_history';
  static const int _maxEntries = 100;

  /// Returns stored history, newest first. Never returns fakes.
  static Future<List<ScanHistoryEntry>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = json.decode(raw);
      final entries = decoded
          .map((e) => ScanHistoryEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Appends a REAL scan result. Call only with genuine results.
  static Future<void> addEntry(ScanHistoryEntry entry) async {
    final list = await getHistory();
    list.add(entry);
    if (list.length > _maxEntries) {
      list.removeRange(0, list.length - _maxEntries);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
