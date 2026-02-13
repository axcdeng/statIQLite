import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class ExportsScreen extends ConsumerWidget {
  const ExportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.import_export, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              'Export all scouting data to CSV',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final exportService = ref.read(exportServiceProvider);
                final scoutingRepo = ref.read(scoutingRepositoryProvider);
                // Fetch all entries for export
                // This is a simplification; realistically you'd filter or page
                final entries = scoutingRepo.watchEntries().value.values.toList();
                await exportService.shareScoutEntriesCsv(entries);
              },
              icon: const Icon(Icons.share),
              label: const Text('Export to CSV'),
            ),
            const SizedBox(height: 10),
            // XLSX Stub
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement XLSX using excel package
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('XLSX export coming soon (requires syncfusion or excel package logic)')),
                );
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Export to Excel (XLSX)'),
            ),
          ],
        ),
      ),
    );
  }
}
