import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class TeamsRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;

  TeamsRepository(this._apiClient, this._localDb);

  Future<void> fetchTeams(int eventId) async {
    try {
      final teams = await _apiClient.getTeams(eventId);
      // Store with composite key: "eventId_teamId"
      // Also update the team object to know which event it belongs to contextually
      final teamsMap = <dynamic, Team>{};
      for (var t in teams) {
        final teamWithEvent = t.copyWith(eventId: eventId);
        teamsMap['${eventId}_${t.id}'] = teamWithEvent;
      }
      await _localDb.teamsBox.putAll(teamsMap);
    } catch (e) {
      rethrow;
    }
  }

  ValueListenable<Box<Team>> watchTeams() {
    return _localDb.teamsBox.listenable();
  }

  List<Team> getTeamsForEvent(int eventId) {
    // Filter by eventId property since we now store it correctly
    return _localDb.teamsBox.values.where((t) => t.eventId == eventId).toList();
  }

  /// Instant local lookup — checks Hive cache for any previously loaded team.
  Team? findLocalTeamByNumber(String number) {
    try {
      return _localDb.teamsBox.values.firstWhere((t) => t.number == number);
    } catch (_) {
      return null;
    }
  }

  /// Fast API lookup via RobotEvents (skips the slower RoboStem proxy).
  Future<Team?> getTeamByNumber(String number) async {
    return await _apiClient.getTeamByNumber(number);
  }

  Future<List<Team>> searchTeams(String query) async {
    // Querying by team number
    return await _apiClient.searchTeams(number: query, limit: 1);
  }

  Future<Map<String, dynamic>?> getTeamSkillRank(String teamNumber,
      {String? gradeLevel}) async {
    return await _apiClient.getTeamSkillRank(teamNumber,
        gradeLevel: gradeLevel);
  }

  Future<List<Map<String, dynamic>>> getTeamSkills(int teamId) async {
    return await _apiClient.getTeamSkills(teamId);
  }

  Future<List<Map<String, dynamic>>> getTeamAwards(int teamId) async {
    return await _apiClient.getTeamAwards(teamId);
  }

  Future<List<Event>> getTeamEvents(int teamId, {int? seasonId}) async {
    return await _apiClient.getTeamEvents(teamId, seasonId: seasonId);
  }
}
