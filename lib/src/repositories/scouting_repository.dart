import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/scout_entry_model.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class ScoutingRepository {
  final LocalDbService _localDb;

  ScoutingRepository(this._localDb);

  Future<void> saveEntry(ScoutEntry entry) async {
    await _localDb.scoutEntriesBox.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _localDb.scoutEntriesBox.delete(id);
  }

  ValueListenable<Box<ScoutEntry>> watchEntries() {
    return _localDb.scoutEntriesBox.listenable();
  }
  
  List<ScoutEntry> getEntriesForMatch(int matchId) {
    return _localDb.scoutEntriesBox.values.where((e) => e.matchId == matchId).toList();
  }
  
  List<ScoutEntry> getEntriesForTeam(String teamNumber) {
    return _localDb.scoutEntriesBox.values.where((e) => e.teamNumber == teamNumber).toList();
  }
}
