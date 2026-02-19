import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roboscout_iq/src/models/scout_entry_model.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> shareScoutEntriesCsv(List<ScoutEntry> entries) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Event ID',
      'Match ID',
      'Team Number',
      'Scout Name',
      'Timestamp',
      'Notes',
      // Dynamic fields logic would go here to flatten the map
      'Data Fields (JSON)'
    ]);

    for (var entry in entries) {
      rows.add([
        entry.eventId,
        entry.matchId,
        entry.teamNumber,
        entry.scoutName,
        entry.timestamp.toIso8601String(),
        entry.notes,
        entry.data.toString()
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/roboscout_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: 'RoboScout IQ Export');
  }
}
