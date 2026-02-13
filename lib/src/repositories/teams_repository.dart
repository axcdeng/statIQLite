import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      await _localDb.teamsBox.putAll({for (var t in teams) t.id: t});
    } catch (e) {
      rethrow;
    }
  }

  ValueListenable<Box<Team>> watchTeams() {
    return _localDb.teamsBox.listenable();
  }

  List<Team> getTeamsForEvent(int eventId) {
    return _localDb.teamsBox.values.where((t) => t.eventId == eventId).toList();
  }

  Future<List<Team>> searchTeams(String query) async {
    // If query is numeric, assume team number search
    // TODO: support other search types if needed
    return await _apiClient.searchTeams(number: query, limit: 20);
  }

  Future<List<Map<String, dynamic>>> getTeamSkills(int teamId) async {
    return await _apiClient.getTeamSkills(teamId);
  }

  Future<List<Map<String, dynamic>>> getTeamAwards(int teamId) async {
    return await _apiClient.getTeamAwards(teamId);
  }

  Future<List<dynamic>> getTeamEvents(int teamId) async {
    return await _apiClient.getTeamEvents(teamId);
  }
}
