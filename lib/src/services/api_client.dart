import 'package:dio/dio.dart';
import 'package:roboscout_iq/src/constants.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/services/secure_storage_service.dart';
import 'package:roboscout_iq/src/state/settings_provider.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final SettingsState _settings;

  ApiClient(this._secureStorage, this._settings)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.robotEventsBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('--- REQUEST ---');
        print('Path: ${options.path}');
        print('Headers: ${options.headers}');
        print('Query Params: ${options.queryParameters}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('--- RESPONSE ---');
        print('Status: ${response.statusCode}');
        print('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('--- ERROR ---');
        print('Status: ${e.response?.statusCode}');
        print('Message: ${e.message}');
        print('Response Data: ${e.response?.data}');
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
        print(
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

      print(
          'DEBUG _fetchAllPages: page $currentPage/${lastPage ?? "?"}, got ${data.length} items (total so far: ${allItems.length})');

      // Stop if we've reached the last page or got no data
      if (data.isEmpty || (lastPage != null && currentPage >= lastPage)) {
        break;
      }
      currentPage++;
    }

    print(
        'DEBUG _fetchAllPages: DONE. Total items fetched: ${allItems.length}');
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
      print(
          'DEBUG getEvents: Fetched ${events.length} events for range ${from.toIso8601String()} to ${to.toIso8601String()}');
      return events;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Team>> getTeams(int eventId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/events/$eventId/teams');
      final data = response.data['data'] as List;
      return data.map((json) => Team.fromJson(json)).toList();
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
      print(
          'DEBUG _getDivisions: Fetching event details for $eventId to find divisions...');
      final response = await _dio.get('/events/$eventId');
      final data = response.data;

      print('DEBUG _getDivisions: Response status ${response.statusCode}');
      if (data != null) {
        if (data is Map) {
          print('DEBUG _getDivisions: Data keys: ${data.keys.toList()}');
          if (data['divisions'] != null) {
            print('DEBUG _getDivisions: Found divisions: ${data['divisions']}');
            return (data['divisions'] as List).cast<Map<String, dynamic>>();
          } else {
            print('DEBUG _getDivisions: "divisions" key is null or missing.');
          }
        } else {
          print(
              'DEBUG _getDivisions: Data is not a Map! Type: ${data.runtimeType}');
        }
      } else {
        print('DEBUG _getDivisions: Response data is null.');
      }
      return [];
    } catch (e) {
      print('Error fetching event details for divisions: $e');
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
              print('Warning: Failed to fetch matches for division $divId: $e');
            }
          }
          if (allMatches.isNotEmpty) {
            divisionFetchSuccess = true;
          }
        }
      } catch (e) {
        print(
            'Warning: Failed to fetch divisions checks for event $eventId: $e');
      }

      // 2. Fallback: If no matches found via divisions, try direct endpoint
      if (!divisionFetchSuccess || allMatches.isEmpty) {
        print(
            'DEBUG: No matches from divisions, trying direct endpoint for event $eventId');
        try {
          final matches = await _fetchAllPages('/events/$eventId/matches', {},
              perPage: 250);
          allMatches.addAll(matches.map((json) => MatchModel.fromJson(json)));
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 404) {
            print('DEBUG: Direct matches endpoint also 404 for event $eventId');
          } else {
            print('Error fetching direct matches: $e');
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
    // RoboStem API uses a different base URL and key
    final token = _settings.roboStemApiKey ?? AppConstants.roboStemApiKey;
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.roboStemBaseUrl, // https://api.robostem-api.org
      headers: {
        'x-api-key': token,
        'accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      print('DEBUG calling RoboStem: /api/skills/global with params: ${{
        'program': 'VIQRC',
        'limit': 100,
        'grade_level': gradeLevel,
      }}');

      final response = await dio.get('/api/skills/global', queryParameters: {
        'program': 'VIQRC',
        'limit': 100, // Reduced from 2500 for performance
        'grade_level': gradeLevel,
      });

      // RoboStem response structure might differ. Assuming standard list or {data: []}
      List<Map<String, dynamic>> rawList = [];
      if (response.data is List) {
        rawList = (response.data as List).cast<Map<String, dynamic>>();
      } else if (response.data is Map && response.data['data'] is List) {
        rawList = (response.data['data'] as List).cast<Map<String, dynamic>>();
      }

      // Client-side filter fallback (just in case API returns mixed results)
      // The sample response shows 'grade_level': 'Middle School' or 'Elementary School'
      final filteredList = rawList.where((item) {
        final g = item['grade_level'];
        // Compare loosely or exactly? Let's try exact match first
        return g == gradeLevel;
      }).toList();

      if (filteredList.length < rawList.length) {
        print(
            'DEBUG: Client-side filtered ${rawList.length - filteredList.length} items that did not match $gradeLevel');
      }

      return filteredList;
    } catch (e) {
      if (e is DioException) {
        print('RoboStem API Error: ${e.message} ${e.response?.statusCode}');
      }
      return [];
    }
  }

  Future<List<Team>> searchTeams(
      {String? number, int? program, int? limit}) async {
    // Strategy: Use RobotEvents API for exact team lookup first,
    // then enrich with RoboStem stats data.

    if (number != null) {
      // 1. Get exact team from RobotEvents API (uses number[] for exact match)
      final reTeam = await getTeamByNumber(number);

      if (reTeam != null) {
        // 2. Try to enrich with RoboStem stats
        try {
          final token = _settings.roboStemApiKey ?? AppConstants.roboStemApiKey;
          final dio = Dio(BaseOptions(
            baseUrl: AppConstants.roboStemBaseUrl,
            headers: {
              'x-api-key': token,
              'accept': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));

          final response = await dio.get('/api/teams', queryParameters: {
            'number': reTeam.number,
            'limit': 5,
          });

          List<dynamic> data;
          if (response.data is Map && response.data.containsKey('data')) {
            data = response.data['data'] as List;
          } else if (response.data is List) {
            data = response.data as List;
          } else {
            data = [];
          }

          // Find exact match in RoboStem results by team number
          final roboStemMatch = data
              .cast<Map<String, dynamic>>()
              .where((d) =>
                  (d['number'] as String?)?.toUpperCase() ==
                  reTeam.number.toUpperCase())
              .toList();

          if (roboStemMatch.isNotEmpty) {
            // Merge RoboStem stats into the RobotEvents team
            final enriched = Team.fromJson(roboStemMatch.first);
            return [
              enriched.copyWith(
                id: reTeam.id, // Keep RobotEvents ID for match lookups
              )
            ];
          }
        } catch (e) {
          print('RoboStem enrichment failed, using RobotEvents data: $e');
        }

        // Return RobotEvents team even without RoboStem enrichment
        return [reTeam];
      }
    }

    // Fallback: Generic RoboStem search (for non-number queries or if RE fails)
    try {
      final token = _settings.roboStemApiKey ?? AppConstants.roboStemApiKey;
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.roboStemBaseUrl,
        headers: {
          'x-api-key': token,
          'accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      final queryParams = <String, dynamic>{
        if (number != null) 'number': number,
        if (program != null) 'program': program,
        if (limit != null) 'limit': limit,
      };

      final response =
          await dio.get('/api/teams', queryParameters: queryParams);

      List<dynamic> data;
      if (response.data is Map && response.data.containsKey('data')) {
        data = response.data['data'] as List;
      } else if (response.data is List) {
        data = response.data as List;
      } else {
        return [];
      }

      return data.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        print('RoboStem API Search Error: ${e.message}');
      }
      return [];
    }
  }

  /// Fetches the World Skills rank for a specific team using the `team` param.
  Future<Map<String, dynamic>?> getTeamSkillRank(String teamNumber,
      {String? gradeLevel}) async {
    final token = _settings.roboStemApiKey ?? AppConstants.roboStemApiKey;
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.roboStemBaseUrl,
      headers: {
        'x-api-key': token,
        'accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      final queryParams = <String, dynamic>{
        'team': teamNumber,
        'limit': 1,
      };
      // If we know the grade level, filter by it for a more precise result
      if (gradeLevel != null) {
        queryParams['grade_level'] = gradeLevel;
      }

      final response =
          await dio.get('/api/skills/global', queryParameters: queryParams);

      List<dynamic> data;
      if (response.data is Map && response.data.containsKey('data')) {
        data = response.data['data'] as List;
      } else if (response.data is List) {
        data = response.data as List;
      } else {
        return null;
      }

      if (data.isNotEmpty) {
        return data.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching team skill rank: $e');
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
      print(
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
          allRankings.addAll(pages);
        } catch (e) {
          print('Error fetching rankings for division $divId: $e');
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
            allSkills.addAll(pages);
          } catch (e) {
            print('Error fetching skills for division $divId: $e');
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
          print('Error fetching direct skills for event $eventId: $e');
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
      if (seasonId != null) queryParams['season'] = seasonId;

      final response =
          await _dio.get('/teams/$teamId/events', queryParameters: queryParams);
      final data = response.data['data'] as List;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
