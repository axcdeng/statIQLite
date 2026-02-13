class AppConstants {
  static const String appName = 'RoboScout IQ';

  // Secure Storage Keys
  static const String robotEventsApiKeyKey = 'robot_events_api_key';

  // Hive Box Names
  static const String eventsBox = 'events_box';
  static const String teamsBox = 'teams_box';
  static const String matchesBox = 'matches_box';
  static const String scoutEntriesBox = 'scout_entries_box';
  static const String settingsBox = 'settings_box';

  // RobotEvents API
  static const String robotEventsBaseUrl = 'https://api.robostem-api.org/api';
  static const String roboStemApiKey =
      '6ab1d415d0447945ff6e989a081fba659b7f2eb34ab3a2a07451a365aa6114f7';

  // VEX IQ Program ID (usually 41 for VEX IQ, verify via API or documentation)
  static const int vexIqProgramId = 41;
}
