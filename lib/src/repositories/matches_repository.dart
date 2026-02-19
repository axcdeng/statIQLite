import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class MatchesRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;

  // In-memory cache for matches
  final Map<int, List<MatchModel>> _eventMatchesCache = {};

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
        debugPrint(
            'Removed ${staleIds.length} stale matches for event $eventId');
      }

      // 5. Save new/updated matches
      await _localDb.matchesBox.putAll({for (var m in matches) m.id: m});

      // 6. Update cache
      _eventMatchesCache[eventId] = List<MatchModel>.from(matches)
        ..sort((a, b) => (a.scheduledTime ?? DateTime(0))
            .compareTo(b.scheduledTime ?? DateTime(0)));
    } catch (e) {
      rethrow;
    }
  }

  ValueListenable<Box<MatchModel>> watchMatches() {
    return _localDb.matchesBox.listenable();
  }

  List<MatchModel> getMatchesForEvent(int eventId) {
    // 1. Check cache first
    if (_eventMatchesCache.containsKey(eventId)) {
      return _eventMatchesCache[eventId]!;
    }

    // 2. Fallback to box scan
    final matches = _localDb.matchesBox.values
        .where((m) => m.eventId == eventId)
        .toList()
      ..sort((a, b) => (a.scheduledTime ?? DateTime(0))
          .compareTo(b.scheduledTime ?? DateTime(0)));

    // 3. Update cache for next time
    if (matches.isNotEmpty) {
      _eventMatchesCache[eventId] = matches;
    }

    return matches;
  }

  void clearCache() {
    _eventMatchesCache.clear();
  }
}
