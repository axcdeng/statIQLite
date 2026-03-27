import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:roboscout_iq/src/constants.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';

import 'package:roboscout_iq/src/state/settings_provider.dart';

class ApiClient {
  final Dio _dio;
  // final SecureStorageService _secureStorage;
  final SettingsState _settings;
  Dio get dio => _dio;

  ApiClient(this._settings)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.robotEventsBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('REQ: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
            'RES: ${response.statusCode} ${response.requestOptions.path} (${response.data.toString().length} bytes)');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint(
            'ERR: ${e.response?.statusCode} ${e.requestOptions.path} - ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Future<void> _addAuthHeader() async {
    String? token = _settings.robotEventsApiKey;

    // Validate the token if provided
    if (token != null && token.isNotEmpty) {
      // Check if it looks like a RoboStem key (64 chars, hex)
      // RoboStem keys are typically 64 chars long hex strings.
      // RobotEvents keys are JWTs (start with eyJ...)
      final isRoboStemKey =
          token.length == 64 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(token);
      final isJwt = token.startsWith('eyJ');

      if (isRoboStemKey || !isJwt) {
        debugPrint(
            'WARNING: User provided RobotEvents Key looks invalid (RoboStem key? or not JWT). Using default key.');
        token = null; // Fallback to default
      }
    }

    token ??= AppConstants.robotEventsApiToken;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Fetches all pages of a paginated API response.
  /// The RobotEvents API uses per_page/page pagination with meta.last_page.
  Future<List<Map<String, dynamic>>> _fetchAllPages(
    String path,
    Map<String, dynamic> queryParameters, {
    int perPage = 250,
  }) async {
    final allItems = <Map<String, dynamic>>[];
    int currentPage = 1;
    int? lastPage;

    while (true) {
      final params = {
        ...queryParameters,
        'per_page': perPage,
        'page': currentPage,
      };

      final response = await _dio.get(path, queryParameters: params);
      final data = response.data['data'] as List;
      lastPage ??= response.data['meta']?['last_page'] as int?;

      allItems.addAll(data.cast<Map<String, dynamic>>());

      // Stop if we've reached the last page or got no data
      if (data.isEmpty || (lastPage != null && currentPage >= lastPage)) {
        break;
      }
      currentPage++;
    }

    return allItems;
  }

  /// Fetches events for a date range from the RobotEvents API.
  /// The official API properly supports start/end date filtering.
  Future<List<Event>> getEvents({
    required DateTime from,
    required DateTime to,
    int? seasonId,
  }) async {
    await _addAuthHeader();
    try {
      final allItems = await _fetchAllPages('/events', {
        'program[]': AppConstants.vexIqProgramId,
        'start': from.toIso8601String(),
        'end': to.toIso8601String(),
        if (seasonId != null) 'season[]': seasonId,
      });

      final events = allItems.map((json) => Event.fromJson(json)).toList();
      debugPrint(
          'DEBUG getEvents: Fetched ${events.length} events for range ${from.toIso8601String()} to ${to.toIso8601String()}');
      return events;
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> getEvent(int eventId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/events/$eventId');
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Team>> getTeams(int eventId) async {
    await _addAuthHeader();
    try {
      final allItems = await _fetchAllPages('/events/$eventId/teams', {});
      return allItems.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  /// Fast team lookup by number via the main RobotEvents API.
  Future<Team?> getTeamByNumber(String number) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/teams', queryParameters: {
        'number[]': number,
        'program[]': AppConstants.vexIqProgramId,
      });
      final data = response.data['data'] as List;
      if (data.isEmpty) return null;
      return Team.fromJson(data.first);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getDivisions(int eventId) async {
    try {
      debugPrint(
          'DEBUG _getDivisions: Fetching event details for $eventId to find divisions...');
      final response = await _dio.get('/events/$eventId');
      final data = response.data;

      debugPrint('DEBUG _getDivisions: Response status ${response.statusCode}');
      if (data != null) {
        if (data is Map) {
          debugPrint('DEBUG _getDivisions: Data keys: ${data.keys.toList()}');
          if (data['divisions'] != null) {
            debugPrint(
                'DEBUG _getDivisions: Found divisions: ${data['divisions']}');
            return (data['divisions'] as List).cast<Map<String, dynamic>>();
          } else {
            debugPrint(
                'DEBUG _getDivisions: "divisions" key is null or missing.');
          }
        } else {
          debugPrint(
              'DEBUG _getDivisions: Data is not a Map! Type: ${data.runtimeType}');
        }
      } else {
        debugPrint('DEBUG _getDivisions: Response data is null.');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching event details for divisions: $e');
      return [];
    }
  }

  Future<List<MatchModel>> getMatches(int eventId) async {
    await _addAuthHeader();
    try {
      final allMatches = <MatchModel>[];
      bool divisionFetchSuccess = false;

      // 1. Try fetching via Divisions
      try {
        final divisions = await _getDivisions(eventId);
        if (divisions.isNotEmpty) {
          for (final div in divisions) {
            final divId = div['id'];
            try {
              final matches = await _fetchAllPages(
                '/events/$eventId/divisions/$divId/matches',
                {},
                perPage: 250,
              );
              allMatches
                  .addAll(matches.map((json) => MatchModel.fromJson(json)));
            } catch (e) {
              debugPrint(
                  'Warning: Failed to fetch matches for division $divId: $e');
            }
          }
          if (allMatches.isNotEmpty) {
            divisionFetchSuccess = true;
          }
        }
      } catch (e) {
        debugPrint(
            'Warning: Failed to fetch divisions checks for event $eventId: $e');
      }

      // 2. Fallback: If no matches found via divisions, try direct endpoint
      if (!divisionFetchSuccess || allMatches.isEmpty) {
        debugPrint(
            'DEBUG: No matches from divisions, trying direct endpoint for event $eventId');
        try {
          final matches = await _fetchAllPages('/events/$eventId/matches', {},
              perPage: 250);
          allMatches.addAll(matches.map((json) => MatchModel.fromJson(json)));
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 404) {
            debugPrint(
                'DEBUG: Direct matches endpoint also 404 for event $eventId');
          } else {
            debugPrint('Error fetching direct matches: $e');
          }
        }
      }

      return allMatches;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGlobalSkills(
      {String gradeLevel = 'Middle School'}) async {
    // Public RobotEvents season skills endpoint — no auth required.
    // Grade param: 'Middle%20School' or 'Elementary' (not 'Elementary School').
    final String gradeParam = gradeLevel.toLowerCase().contains('elementary')
        ? 'Elementary'
        : 'Middle School';

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    debugPrint(
        'DEBUG calling RobotEvents season skills: grade_level=$gradeParam');

    try {
      final response = await dio.get(
        'https://www.robotevents.com/api/seasons/196/skills',
        queryParameters: {
          'post_season': 0,
          'grade_level': gradeParam,
        },
      );

      List<dynamic> rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      }

      // Normalize nested API shape to the flat shape expected by the
      // repository cache layer and the world skills screen:
      //   rank, team_number, team_name, score, programming_score, driver_score
      return rawList.map((item) {
        final map = item as Map<String, dynamic>;
        final team = map['team'] as Map<String, dynamic>? ?? {};
        final scores = map['scores'] as Map<String, dynamic>? ?? {};
        return <String, dynamic>{
          'rank': map['rank'],
          'team_number': team['team'] ?? '',
          'team_name': team['teamName'] ?? '',
          'organization': team['organization'] ?? '',
          'country': team['country'] ?? '',
          'score': _parseNum(scores['score']) ?? 0,
          'programming_score': _parseNum(scores['programming']) ?? 0,
          'driver_score': _parseNum(scores['driver']) ?? 0,
        };
      }).toList();
    } catch (e) {
      if (e is DioException) {
        debugPrint(
            'RobotEvents skills API error: ${e.message} ${e.response?.statusCode}');
      } else {
        debugPrint('getGlobalSkills error: $e');
      }
      return [];
    }
  }

  /// Parses a value that may arrive as a String or num from the API.
  num? _parseNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  Future<List<Team>> getGlobalSuperscoreRankings(
      {String? country, int limit = 100}) async {
    final token = _settings.roboStemApiKey ?? AppConstants.roboStemApiKey;
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.roboStemBaseUrl,
      headers: {
        'X-API-Key': token,
        'accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      final queryParams = <String, dynamic>{
        'sort': 'superscore',
        'per_page': limit,
        'season[]': [AppConstants.currentSeasonId],
      };

      debugPrint(
          'DEBUG calling RoboStem: /api/v3/superscore/rankings/viqrc with params: $queryParams');

      final response = await dio.get(
        '/api/v3/superscore/rankings/viqrc',
        queryParameters: queryParams,
      );

      List<Map<String, dynamic>> rawList = [];
      if (response.data is Map && response.data['data'] is List) {
        rawList = (response.data['data'] as List).cast<Map<String, dynamic>>();
      } else if (response.data is List) {
        rawList = (response.data as List).cast<Map<String, dynamic>>();
      }

      return rawList.map((json) {
        final team = json['team'] as Map<String, dynamic>? ?? const {};
        final parsedRank = json['rank'] is String
            ? int.tryParse(json['rank'] as String)
            : (json['rank'] as num?)?.toInt();
        final teamMap = <String, dynamic>{
          'id': team['id'],
          'number': team['number'],
          'name': team['name'],
          'worldRank': parsedRank,
          'rank': parsedRank,
          'superscore': _parseNum(json['superscore']),
          'location': json['region'],
        };
        return Team.fromJson(teamMap);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching SuperScore rankings: $e');
      return [];
    }
  }

  Future<List<Team>> searchTeams(
      {String? number, int? program, int? limit}) async {
    // Return only basic team info for speed. Enrichment happens via lazy loading in UI.
    if (number != null) {
      final team = await getTeamByNumber(number);
      return team != null ? [team] : [];
    }

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.robotEventsBaseUrl,
        headers: {
          'Authorization': 'Bearer ${AppConstants.robotEventsApiToken}',
          'accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      final queryParams = <String, dynamic>{
        if (number != null) 'number[]': [number],
        if (program != null) 'program[]': [program],
        if (limit != null) 'per_page': limit,
      };

      final response = await dio.get('/teams', queryParameters: queryParams);
      List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      debugPrint('RobotEvents API Search Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTeamSuperscoreStats(
      int teamId, int seasonId) async {
    try {
      final token = _settings.roboStemApiKey ?? AppConstants.roboStemApiKey;
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.roboStemBaseUrl,
        headers: {
          'X-API-Key': token,
          'accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      final response = await dio.get(
        '/api/v3/superscore/rankings/viqrc',
        queryParameters: {
          'sort': 'superscore',
          'season[]': [seasonId],
          'team[]': [teamId],
          'per_page': 1,
        },
      );

      if (response.data is Map && response.data['data'] is List) {
        final rows = response.data['data'] as List;
        if (rows.isEmpty) return null;
        final row = Map<String, dynamic>.from(rows.first as Map);
        final superscore = _parseNum(row['superscore'])?.toDouble();
        final rank = row['rank'] is String
            ? int.tryParse(row['rank'] as String)
            : (row['rank'] as num?)?.toInt();
        return {
          'rank': rank,
          'superscore': superscore,
          'scaledSuperscore':
              superscore == null ? null : (superscore * 17.0).toDouble(),
        };
      }
    } catch (e) {
      debugPrint('Error fetching team SuperScore stats: $e');
    }
    return null;
  }

  /// Searches up to 4 pages of the RobotEvents season skills leaderboard to find a team's rank.
  Future<Map<String, dynamic>?> getTeamSkillRank(String teamNumber,
      {String? gradeLevel}) async {
    try {
      String grade = 'Middle%20School';
      if (gradeLevel != null) {
        if (gradeLevel.toLowerCase().contains('elementary')) {
          grade = 'Elementary';
        }
      }

      for (int page = 1; page <= 4; page++) {
        final url =
            'https://www.robotevents.com/api/seasons/${AppConstants.currentSeasonId}/skills?post_season=0&grade_level=$grade&page=$page';
        final response = await _dio.get(url);

        if (response.data is List) {
          final data = response.data as List;
          final match = data.firstWhere(
            (item) =>
                (item['team']['team'] as String).toUpperCase() ==
                teamNumber.toUpperCase(),
            orElse: () => null,
          );

          if (match != null) {
            return {
              'rank': match['rank'],
              'score': match['scores']['score'],
            };
          }
        } else {
          break;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error searching World Skills rank: $e');
      return null;
    }
  }

  /// Calculates the highest combined (driver + programming) skills score for a team in a season.
  Future<int?> getTeamWorldBestSkills(int teamId, int seasonId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/teams/$teamId/skills',
          queryParameters: {'season[]': seasonId});
      final data = response.data['data'] as List;

      if (data.isEmpty) return null;

      // Group by event ID to find best combined score at a single event
      final eventScores = <int, Map<String, int>>{};

      for (var skill in data) {
        final eventId = skill['event']['id'] as int;
        final type = skill['type'] as String; // 'driver' or 'programming'
        final score = skill['score'] as int;

        eventScores.putIfAbsent(eventId, () => {'driver': 0, 'programming': 0});
        if (type == 'driver') {
          if (score > eventScores[eventId]!['driver']!) {
            eventScores[eventId]!['driver'] = score;
          }
        } else if (type == 'programming') {
          if (score > eventScores[eventId]!['programming']!) {
            eventScores[eventId]!['programming'] = score;
          }
        }
      }

      int maxCombined = 0;
      for (var scores in eventScores.values) {
        final combined = scores['driver']! + scores['programming']!;
        if (combined > maxCombined) {
          maxCombined = combined;
        }
      }

      return maxCombined > 0 ? maxCombined : null;
    } catch (e) {
      debugPrint('Error fetching team best skills: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTeamSkills(int teamId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/teams/$teamId/skills');
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      // It's possible for matches/skills to be empty or 404
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTeamAwards(int teamId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/teams/$teamId/awards');
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<List<Event>> searchEvents({
    String? name,
    int? seasonId,
    DateTime? start,
    DateTime? end,
    List<String>? skus,
  }) async {
    await _addAuthHeader();
    try {
      final queryParams = <String, dynamic>{
        if (name != null) 'name': name,
        'program[]': AppConstants.vexIqProgramId,
        if (seasonId != null) 'season[]': seasonId,
        if (end != null) 'end': end.toIso8601String(),
        if (skus != null) 'sku[]': skus,
      };

      final allItems = await _fetchAllPages('/events', queryParams);
      final events = allItems.map((json) => Event.fromJson(json)).toList();
      debugPrint(
          'DEBUG searchEvents: Found ${events.length} events (name=$name, start=$start, end=$end)');
      return events;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEventRankings(int eventId) async {
    await _addAuthHeader();
    try {
      final divisions = await _getDivisions(eventId);
      final allRankings = <Map<String, dynamic>>[];

      for (final div in divisions) {
        final divId = div['id'];
        try {
          final pages = await _fetchAllPages(
            '/events/$eventId/divisions/$divId/rankings',
            {},
            perPage: 250,
          );
          // Inject division ID
          for (var item in pages) {
            item['divisionId'] = divId;
          }
          allRankings.addAll(pages);
        } catch (e) {
          debugPrint('Error fetching rankings for division $divId: $e');
        }
      }
      return allRankings;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFinalistRankings(int eventId) async {
    await _addAuthHeader();
    try {
      final divisions = await _getDivisions(eventId);
      final allRankings = <Map<String, dynamic>>[];

      for (final div in divisions) {
        final divId = div['id'];
        try {
          final pages = await _fetchAllPages(
            '/events/$eventId/divisions/$divId/finalistRankings',
            {},
            perPage: 250,
          );
          // Inject division ID
          for (var item in pages) {
            item['divisionId'] = divId;
          }
          allRankings.addAll(pages);
        } catch (e) {
          debugPrint(
              'Error fetching finalist rankings for division $divId: $e');
        }
      }
      return allRankings;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEventAwards(int eventId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/events/$eventId/awards');
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEventSkills(int eventId) async {
    await _addAuthHeader();
    try {
      final divisions = await _getDivisions(eventId);
      final allSkills = <Map<String, dynamic>>[];

      if (divisions.isNotEmpty) {
        for (final div in divisions) {
          final divId = div['id'];
          try {
            final pages = await _fetchAllPages(
              '/events/$eventId/divisions/$divId/skills',
              {},
              perPage: 250,
            );
            // Inject division ID
            for (var item in pages) {
              item['divisionId'] = divId;
            }
            allSkills.addAll(pages);
          } catch (e) {
            debugPrint('Error fetching skills for division $divId: $e');
          }
        }
      }

      // Fallback: try direct endpoint if no divisions found
      if (allSkills.isEmpty) {
        try {
          final pages = await _fetchAllPages(
            '/events/$eventId/skills',
            {},
            perPage: 250,
          );
          allSkills.addAll(pages);
        } catch (e) {
          debugPrint('Error fetching direct skills for event $eventId: $e');
        }
      }

      return allSkills;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Event>> getTeamEvents(int teamId, {int? seasonId}) async {
    await _addAuthHeader();
    try {
      final queryParams = <String, dynamic>{};
      if (seasonId != null) queryParams['season[]'] = seasonId;

      final allItems =
          await _fetchAllPages('/teams/$teamId/events', queryParams);
      return allItems.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
