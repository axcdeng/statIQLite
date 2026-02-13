import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/constants.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/scout_entry_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';

class LocalDbService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    // TODO: Verify typeIds in generated adapters match here
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(TeamAdapter());
    Hive.registerAdapter(MatchAdapter());
    Hive.registerAdapter(ScoutEntryAdapter());
    
    // Open boxes
    await Hive.openBox<Event>(AppConstants.eventsBox);
    await Hive.openBox<Team>(AppConstants.teamsBox);
    await Hive.openBox<MatchModel>(AppConstants.matchesBox);
    await Hive.openBox<ScoutEntry>(AppConstants.scoutEntriesBox);
    await Hive.openBox(AppConstants.settingsBox);
  }

  Box<Event> get eventsBox => Hive.box<Event>(AppConstants.eventsBox);
  Box<Team> get teamsBox => Hive.box<Team>(AppConstants.teamsBox);
  Box<MatchModel> get matchesBox => Hive.box<MatchModel>(AppConstants.matchesBox);
  Box<ScoutEntry> get scoutEntriesBox => Hive.box<ScoutEntry>(AppConstants.scoutEntriesBox);
  Box get settingsBox => Hive.box(AppConstants.settingsBox);

  Future<void> clearAllData() async {
    await eventsBox.clear();
    await teamsBox.clear();
    await matchesBox.clear();
    await scoutEntriesBox.clear();
    await settingsBox.clear();
  }
}
