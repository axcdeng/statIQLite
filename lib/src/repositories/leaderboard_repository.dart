import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class LeaderboardRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;

  LeaderboardRepository(this._apiClient, this._localDb);

  Future<List<Map<String, dynamic>>> getGlobalSkills(String gradeLevel,
      {bool forceRefresh = false}) async {
    final cacheKey = 'skills_$gradeLevel';
    final box = _localDb.leaderboardBox;

    if (!forceRefresh && box.containsKey(cacheKey)) {
      try {
        final cachedData = box.get(cacheKey);
        if (cachedData is List) {
          return cachedData
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (e) {
        print('Error reading skills cache: $e');
      }
    }

    try {
      final data = await _apiClient.getGlobalSkills(gradeLevel: gradeLevel);
      await box.put(cacheKey, data);
      return data;
    } catch (e) {
      if (box.containsKey(cacheKey)) {
        final cachedData = box.get(cacheKey);
        if (cachedData is List) {
          return cachedData
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
      rethrow;
    }
  }

  Future<List<Team>> getGlobalTrueSkillRankings(
      {bool forceRefresh = false}) async {
    const cacheKey = 'trueskill_global';
    final box = _localDb.leaderboardBox;

    if (!forceRefresh && box.containsKey(cacheKey)) {
      try {
        final cachedData = box.get(cacheKey);
        if (cachedData is List) {
          return _deserializeTeams(cachedData);
        }
      } catch (e) {
        print('Error reading trueskill cache: $e');
      }
    }

    try {
      final teams = await _apiClient.getGlobalTrueSkillRankings();
      final jsonList = teams.map((t) => t.toJson()).toList();
      await box.put(cacheKey, jsonList);
      return teams;
    } catch (e) {
      if (box.containsKey(cacheKey)) {
        final cachedData = box.get(cacheKey) as List;
        return _deserializeTeams(cachedData);
      }
      rethrow;
    }
  }

  List<Team> _deserializeTeams(List<dynamic> list) {
    return list.map((e) {
      // Hive returns _Map<dynamic, dynamic>, need to cast to Map<String, dynamic>
      // for Team.fromJson
      final json = Map<String, dynamic>.from(e as Map);
      return Team.fromJson(json);
    }).toList();
  }
}
