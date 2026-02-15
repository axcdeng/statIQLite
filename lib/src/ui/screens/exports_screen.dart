import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class ExportsScreen extends ConsumerWidget {
  const ExportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF49CAEB);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Export Data'),
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.share_up,
                    size: 80, color: primaryColor),
                const SizedBox(height: 24),
                const Text(
                  'Export scouting data to CSV',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share your scouting entries with other teams via CSV or open in Spreadsheet applications.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(height: 48),
                CupertinoButton(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () async {
                    final exportService = ref.read(exportServiceProvider);
                    final scoutingRepo = ref.read(scoutingRepositoryProvider);
                    final entries =
                        scoutingRepo.watchEntries().value.values.toList();
                    await exportService.shareScoutEntriesCsv(entries);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(CupertinoIcons.share),
                      SizedBox(width: 8),
                      Text('Export to CSV',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Text('Export to Excel (XLSX)',
                      style: TextStyle(color: primaryColor)),
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Coming Soon'),
                        content: const Text(
                            'XLSX export is currently in development.'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
