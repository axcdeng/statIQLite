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
    return _localDb.matchesBox.values.where((m) => m.eventId == eventId).toList()
      ..sort((a, b) => (a.scheduledTime ?? DateTime(0)).compareTo(b.scheduledTime ?? DateTime(0)));
  }
}
