import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class MatchesRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;

  MatchesRepository(this._apiClient, this._localDb);

  Future<void> fetchMatches(int eventId) async {
    try {
      final matches = await _apiClient.getMatches(eventId);

      // Synchronization Logic:
      // 1. Identify all existing match IDs for this event in local DB
      final existingMatchesForEvent = _localDb.matchesBox.values
          .where((m) => m.eventId == eventId)
          .map((m) => m.id)
          .toSet();

      // 2. Identify IDs present in the new API response
      final newMatchIds = matches.map((m) => m.id).toSet();

      // 3. Find stale IDs (present locally but not in new response)
      final staleIds = existingMatchesForEvent.difference(newMatchIds);

      // 4. Delete stale matches
      if (staleIds.isNotEmpty) {
        await _localDb.matchesBox.deleteAll(staleIds);
        // print('Removed ${staleIds.length} stale matches for event $eventId');
      }

      // 5. Save new/updated matches
      await _localDb.matchesBox.putAll({for (var m in matches) m.id: m});
    } catch (e) {
      rethrow;
    }
  }

  ValueListenable<Box<MatchModel>> watchMatches() {
    return _localDb.matchesBox.listenable();
  }

  List<MatchModel> getMatchesForEvent(int eventId) {
    // Filter by eventId
    return _localDb.matchesBox.values
        .where((m) => m.eventId == eventId)
        .toList()
      ..sort((a, b) => (a.scheduledTime ?? DateTime(0))
          .compareTo(b.scheduledTime ?? DateTime(0)));
  }
}
