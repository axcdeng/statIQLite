import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

/// TTL after which cached leaderboard data is treated as expired.
const Duration _kCacheTtl = Duration(hours: 24);

class LeaderboardRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;

  LeaderboardRepository(this._apiClient, this._localDb);

  // ---------------------------------------------------------------------------
  // In-flight gate — prevents concurrent duplicate fetches for the same key.
  // ---------------------------------------------------------------------------
  final Set<String> _activeFetches = {};

  // ---------------------------------------------------------------------------
  // Global TrueSkill rank memory cache (Number → worldRank)
  // Used to inject global rank when a country filter is active.
  // ---------------------------------------------------------------------------
  Map<String, int> _globalRankCache = {};
  DateTime? _lastGlobalCacheFetch;

  // ---------------------------------------------------------------------------
  // Hive helpers
  // ---------------------------------------------------------------------------

  /// SHA-256 fingerprint of a JSON-serializable list.
  String _fingerprint(List<dynamic> data) {
    final bytes = utf8.encode(jsonEncode(data));
    return sha256.convert(bytes).toString();
  }

  Box get _box => _localDb.leaderboardBox;

  /// Reads a cached list from Hive. Returns null if missing, corrupted, or expired.
  List<Map<String, dynamic>>? _readCache(String key) {
    try {
      final ts = _box.get('${key}_ts') as int?;
      if (ts == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > _kCacheTtl.inMilliseconds) return null; // expired

      final raw = _box.get(key);
      if (raw is! List) return null;
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('LeaderboardRepo: cache read error for $key: $e');
      return null;
    }
  }

  /// Writes [data] to Hive only if the hash has changed.
  /// Swallows write errors to leave stale cache intact.
  Future<void> _writeCache(String key, List<dynamic> data) async {
    try {
      final newHash = _fingerprint(data);
      final oldHash = _box.get('${key}_hash') as String?;
      if (newHash == oldHash) return; // identical — skip write

      await _box.put(key, data);
      await _box.put('${key}_hash', newHash);
      await _box.put('${key}_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('LeaderboardRepo: cache write error for $key: $e');
      // Intentionally not rethrowing — stale cache is preferable to a crash.
    }
  }

  // ---------------------------------------------------------------------------
  // Global Skills (World Skills Rankings)
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getGlobalSkills(String gradeLevel,
      {bool forceRefresh = false}) async {
    final cacheKey = 'skills_$gradeLevel';

    // 1. Serve from cache if valid and not forcing a refresh.
    if (!forceRefresh) {
      final cached = _readCache(cacheKey);
      if (cached != null) return cached;
    }

    // 2. Gate concurrent fetches for the same key.
    if (_activeFetches.contains(cacheKey)) {
      final cached = _readCache(cacheKey);
      return cached ?? [];
    }
    _activeFetches.add(cacheKey);

    try {
      final data = await _apiClient.getGlobalSkills(gradeLevel: gradeLevel);
      await _writeCache(cacheKey, data);
      return data;
    } catch (e) {
      // On network failure return stale cache regardless of TTL.
      try {
        final raw = _box.get(cacheKey);
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } catch (_) {}
      rethrow;
    } finally {
      _activeFetches.remove(cacheKey);
    }
  }

  // ---------------------------------------------------------------------------
  // Global TrueSkill Rankings
  // ---------------------------------------------------------------------------

  Future<void> _ensureGlobalRankCache() async {
    if (_globalRankCache.isEmpty ||
        _lastGlobalCacheFetch == null ||
        DateTime.now().difference(_lastGlobalCacheFetch!) >
            const Duration(hours: 1)) {
      try {
        final globalTeams =
            await _apiClient.getGlobalTrueSkillRankings(limit: 500);
        _globalRankCache = {
          for (var team in globalTeams) team.number: team.worldRank ?? 0
        };
        _lastGlobalCacheFetch = DateTime.now();
      } catch (e) {
        debugPrint('LeaderboardRepo: global rank cache refresh failed: $e');
      }
    }
  }

  Future<List<Team>> getGlobalTrueSkillRankings(
      {String? country, bool forceRefresh = false}) async {
    final cacheKey = 'trueskill_pure_global_${country ?? ""}';

    // 1. Serve from cache if valid.
    if (!forceRefresh) {
      final cached = _readCache(cacheKey);
      if (cached != null) {
        final teams = _deserializeTeams(cached);
        await _ensureGlobalRankCache();
        return _injectGlobalRanks(teams);
      }
    }

    // 2. Gate concurrent fetches.
    if (_activeFetches.contains(cacheKey)) {
      final cached = _readCache(cacheKey);
      if (cached != null) return _deserializeTeams(cached);
      return [];
    }
    _activeFetches.add(cacheKey);

    try {
      if (country != null) await _ensureGlobalRankCache();

      final teams = await _apiClient.getGlobalTrueSkillRankings(
        country: country,
      );

      final enriched = _injectGlobalRanks(teams);
      final jsonList = enriched.map((t) => t.toJson()).toList();
      await _writeCache(cacheKey, jsonList);
      return enriched;
    } catch (e) {
      // On failure return stale cache regardless of TTL.
      try {
        final raw = _box.get(cacheKey);
        if (raw is List) return _deserializeTeams(raw);
      } catch (_) {}
      rethrow;
    } finally {
      _activeFetches.remove(cacheKey);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<Team> _injectGlobalRanks(List<Team> teams) {
    if (_globalRankCache.isEmpty) return teams;
    return teams.map((t) {
      final globalRank = _globalRankCache[t.number];
      return globalRank != null ? t.copyWith(worldRank: globalRank) : t;
    }).toList();
  }

  List<Team> _deserializeTeams(List<dynamic> list) {
    return list.map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      return Team.fromJson(json);
    }).toList();
  }
}
