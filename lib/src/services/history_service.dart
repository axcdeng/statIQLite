import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class HistoryService {
  final LocalDbService _localDb;
  static const int _maxHistory = 15;

  HistoryService(this._localDb);

  Future<void> addTeamToHistory(Team team) async {
    final box = _localDb.teamHistoryBox;

    // Remove if already exists to move to top
    final existingIndex =
        box.values.toList().indexWhere((t) => t.number == team.number);
    if (existingIndex != -1) {
      await box.deleteAt(existingIndex);
    }

    await box.add(team);

    // Enforce limit
    if (box.length > _maxHistory) {
      await box.deleteAt(0);
    }
  }

  Future<void> addEventToHistory(Event event) async {
    final box = _localDb.eventHistoryBox;

    // Remove if already exists to move to top
    final existingIndex =
        box.values.toList().indexWhere((e) => e.id == event.id);
    if (existingIndex != -1) {
      await box.deleteAt(existingIndex);
    }

    await box.add(event);

    // Enforce limit
    if (box.length > _maxHistory) {
      await box.deleteAt(0);
    }
  }

  List<Team> getRecentTeams() {
    return _localDb.teamHistoryBox.values.toList().reversed.toList();
  }

  List<Event> getRecentEvents() {
    return _localDb.eventHistoryBox.values.toList().reversed.toList();
  }

  Future<void> clearHistory() async {
    await _localDb.teamHistoryBox.clear();
    await _localDb.eventHistoryBox.clear();
  }
}
