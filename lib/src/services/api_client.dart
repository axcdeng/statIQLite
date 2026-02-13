import 'package:dio/dio.dart';
import 'package:roboscout_iq/src/constants.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/services/secure_storage_service.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient(this._secureStorage)
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
    var token = await _secureStorage.getApiKey();

    // Check if the stored token matches our hardcoded valid key.
    // If it's null, or a JWT (starts with 'ey'), or just different, we update it.
    if (token == null || token != AppConstants.roboStemApiKey) {
      print(
          'DEBUG: Stale/Missing key detected in storage. Updating to valid key.');
      token = AppConstants.roboStemApiKey;
      await _secureStorage.saveApiKey(token);
    }

    if (token != null) {
      _dio.options.headers['x-api-key'] = token;
      print('DEBUG: Auth Key set: ${token.substring(0, 5)}...');
    } else {
      print('DEBUG: Auth Key is NULL!');
    }
  }

  Future<List<Event>> getEvents({
    required DateTime from,
    required DateTime to,
    int limit = 250,
  }) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/events', queryParameters: {
        'program': AppConstants.vexIqProgramId,
        'start': from.toIso8601String(),
        'end': to.toIso8601String(),
        'limit': limit,
      });
      final data = response.data['data'] as List;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // TODO: Handle errors properly
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
      rethrow;
    }
  }

  Future<List<MatchModel>> getMatches(int eventId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/events/$eventId/matches');
      final data = response.data['data'] as List;
      return data.map((json) => MatchModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGlobalSkills() async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/skills/global', queryParameters: {
        'program': AppConstants.vexIqProgramId,
        'season': 181, // TODO: Make dynamic or configurable
        'grade_level': 'Middle School', // TODO: Make configurable
        'limit': 100,
      });
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Team>> searchTeams(
      {String? number, int? program, int? limit}) async {
    await _addAuthHeader();
    try {
      final queryParams = <String, dynamic>{
        if (number != null) 'number': number,
        if (program != null) 'program': program,
        if (limit != null) 'limit': limit,
      };

      // If searching by number, use the /teams endpoint with query params
      final response = await _dio.get('/teams', queryParameters: queryParams);
      final data = response.data['data'] as List;
      return data.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTeamSkills(int teamId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/teams/$teamId/skills');
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTeamAwards(int teamId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/teams/$teamId/awards');
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Event>> searchEvents({
    String? name,
    int? seasonId,
    DateTime? start,
    DateTime? end,
    int? limit,
  }) async {
    await _addAuthHeader();
    try {
      final queryParams = <String, dynamic>{
        if (name != null) 'name': name,
        'program': AppConstants.vexIqProgramId,
        if (seasonId != null) 'season': seasonId,
        if (start != null) 'start': start.toIso8601String(),
        if (end != null) 'end': end.toIso8601String(),
        if (limit != null) 'limit': limit,
      };

      final response = await _dio.get('/events', queryParameters: queryParams);
      final data = response.data['data'] as List;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEventRankings(int eventId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('/events/$eventId/rankings');
      final data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
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
