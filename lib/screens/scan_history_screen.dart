import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/scan_history_service.dart';
import 'breach_check_screen.dart';

/// Scan History screen.
///
/// Shows ONLY real, locally stored scan results. If nothing has been stored
/// yet, it shows a clean empty state. No fake history is ever generated.
class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<ScanHistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await ScanHistoryService.getHistory();
    if (mounted) {
      setState(() {
        _entries = history;
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    await ScanHistoryService.clear();
    if (mounted) setState(() => _entries = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear history',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.surfaceColor,
                    title: const Text('Clear history?',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'This will remove all locally stored scan history. '
                      'This cannot be undone.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) await _clear();
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _emptyState(context)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final e = _entries[index];
                    final isBreached =
                        e.status == 'breached' || e.breachCount > 0;
                    final color = isBreached ? AppTheme.errorColor : AppTheme.successColor;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isBreached ? Icons.warning_amber : Icons.check_circle,
                          color: color,
                        ),
                        title: Text(_titleFor(e),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${e.email ?? 'Unknown email'} • '
                          '${DateFormat.yMMMd().add_jm().format(e.timestamp)}',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: e.breachCount > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.errorColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${e.breachCount} breaches',
                                    style: TextStyle(
                                        color: AppTheme.errorColor, fontSize: 12)),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }

  String _titleFor(ScanHistoryEntry e) {
    switch (e.status) {
      case 'breached':
        return 'Breach Found';
      case 'safe':
        return 'No Breach Found';
      case 'configMissing':
        return 'Check Unavailable';
      case 'authError':
        return 'API Error';
      case 'networkError':
        return 'Network Error';
      case 'unexpected':
        return 'Service Error';
      default:
        return 'Scan';
    }
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('No scan history yet',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'Your real breach checks will appear here. Run a check to '
              'start building your history.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BreachCheckScreen()),
                ),
                icon: const Icon(Icons.search),
                label: const Text('Run a Breach Check'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
