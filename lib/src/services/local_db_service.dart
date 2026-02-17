import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/constants.dart';
import 'package:roboscout_iq/src/models/division.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/scout_entry_model.dart';
import 'package:roboscout_iq/src/models/score_entry.dart';
import 'package:roboscout_iq/src/models/team_model.dart';

class LocalDbService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    // TODO: Verify typeIds in generated adapters match here
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(DivisionAdapter());
    Hive.registerAdapter(TeamAdapter());
    Hive.registerAdapter(MatchAdapter());
    Hive.registerAdapter(ScoutEntryAdapter());
    Hive.registerAdapter(ScoreEntryAdapter());

    // Open boxes
    // Open boxes in parallel to speed up startup
    // 1. Open CRITICAL boxes (Settings) immediately
    // This must be done before runApp
    await Hive.openBox(AppConstants.settingsBox);
  }

  /// Opens the remaining heavy boxes. Called from SplashScreen.
  static Future<void> ensureOpen() async {
    // Open boxes in parallel to speed up startup
    await Future.wait([
      Hive.openBox<Event>(AppConstants.eventsBox),
      Hive.openBox<Team>(AppConstants.teamsBox),
      Hive.openBox<MatchModel>(AppConstants.matchesBox),
      Hive.openBox<ScoutEntry>(AppConstants.scoutEntriesBox),
      // Settings is already open
      Hive.openBox<ScoreEntry>('saved_scores'),
      Hive.openBox<Team>(AppConstants.teamHistoryBox),
      Hive.openBox<Event>(AppConstants.eventHistoryBox),
      Hive.openBox(AppConstants.leaderboardBox),
    ]);
  }

  Box<Event> get eventsBox => Hive.box<Event>(AppConstants.eventsBox);
  Box<Team> get teamsBox => Hive.box<Team>(AppConstants.teamsBox);
  Box<MatchModel> get matchesBox =>
      Hive.box<MatchModel>(AppConstants.matchesBox);
  Box<ScoutEntry> get scoutEntriesBox =>
      Hive.box<ScoutEntry>(AppConstants.scoutEntriesBox);
  Box get settingsBox => Hive.box(AppConstants.settingsBox);
  Box<ScoreEntry> get scoreEntriesBox => Hive.box<ScoreEntry>('saved_scores');
  Box<Team> get teamHistoryBox => Hive.box<Team>(AppConstants.teamHistoryBox);
  Box<Event> get eventHistoryBox =>
      Hive.box<Event>(AppConstants.eventHistoryBox);
  Box get leaderboardBox => Hive.box(AppConstants.leaderboardBox);

  Future<void> clearAllData() async {
    await eventsBox.clear();
    await teamsBox.clear();
    await matchesBox.clear();
    await scoutEntriesBox.clear();
    await settingsBox.clear();
    await scoreEntriesBox.clear();
    await teamHistoryBox.clear();
    await eventHistoryBox.clear();
    await leaderboardBox.clear();
  }
}
