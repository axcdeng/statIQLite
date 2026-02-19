import 'package:flutter/foundation.dart';
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
        debugPrint('Error reading skills cache: $e');
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

  // Cache for global ranks (Team Number -> Pure TrueSkill Rank)
  Map<String, int> _globalRankCache = {};
  DateTime? _lastGlobalCacheFetch;

  Future<void> _ensureGlobalRankCache() async {
    // Refresh cache if empty or older than 1 hour
    if (_globalRankCache.isEmpty ||
        _lastGlobalCacheFetch == null ||
        DateTime.now().difference(_lastGlobalCacheFetch!) >
            const Duration(hours: 1)) {
      try {
        // Fetch top 500 global teams
        final globalTeams =
            await _apiClient.getGlobalTrueSkillRankings(limit: 500);
        _globalRankCache = {
          for (var team in globalTeams) team.number: team.worldRank ?? 0
        };
        _lastGlobalCacheFetch = DateTime.now();
      } catch (e) {
        debugPrint('Error fetching global rank cache: $e');
      }
    }
  }

  Future<List<Team>> getGlobalTrueSkillRankings(
      {String? country, bool forceRefresh = false}) async {
    final cacheKey = 'trueskill_pure_global_${country ?? ""}';
    final box = _localDb.leaderboardBox;

    if (!forceRefresh && box.containsKey(cacheKey)) {
      try {
        final cachedData = box.get(cacheKey);
        if (cachedData is List) {
          final teams = _deserializeTeams(cachedData);
          // Inject global ranks from memory cache if available, even for disk cached items
          await _ensureGlobalRankCache();
          return teams.map((t) {
            final globalRank = _globalRankCache[t.number];
            return globalRank != null ? t.copyWith(worldRank: globalRank) : t;
          }).toList();
        }
      } catch (e) {
        debugPrint('Error reading trueskill cache: $e');
      }
    }

    try {
      // If filtering, ensure we have global context
      if (country != null) {
        await _ensureGlobalRankCache();
      }

      final teams = await _apiClient.getGlobalTrueSkillRankings(
        country: country,
      );

      // Inject global ranks
      final enrichedTeams = teams.map((t) {
        final globalRank = _globalRankCache[t.number];
        // If we found a global rank, use it. Otherwise keep original (which might be local rank)
        // or set to null if we want to be strict.
        // For now, if found in cache, use it.
        return globalRank != null ? t.copyWith(worldRank: globalRank) : t;
      }).toList();

      final jsonList = enrichedTeams.map((t) => t.toJson()).toList();
      await box.put(cacheKey, jsonList);
      return enrichedTeams;
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
