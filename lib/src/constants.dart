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
  static const String robotEventsBaseUrl = 'https://www.robotevents.com/api/v2';
  static const String robotEventsApiToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiNjZkYjEzZDEyOGIzYjQ3OTQ4YTkwOWNmMTdhNTI5NWE1ZmJlZDRkZjJiYjRhNTYzODk3OGViZjc1ZDEzYTBmMjk1N2RmNzEzZWY4ZTNlYzciLCJpYXQiOjE3NjM2MDI5NjcuNDY4NjYzOSwibmJmIjoxNzYzNjAyOTY3LjQ2ODY2NjEsImV4cCI6MjcxMDI4Nzc2Ny40NjEyMTYsInN1YiI6IjEyNTM1OCIsInNjb3BlcyI6W119.CHRXPJv1ciYEMNsaz0N4jNlAUL8wyW-uyAl-qaLsYfvz8HbGpq22kSmTcn661MR2zJ_RWbCknfCUBog705zVfP7ENO_Ald7ZZpUC--8Rms--hqGoouTHxRKS7u0IBgs7WF7po2JJPukFordXVX1QftwYki5lT6usiDkVNEt38YheOxWsGxaoFMk44H8sCY2V9nsrrw_xsZAQ2U-LNMCQFau0Aznyyt53dtEWCDq76EofIm-HUBqrcT--fQKpt5l4tPaLdof0Ebgbr3aVCNfUuKs16yynW5PJJ42aiNcDlyRZOEqBF3HmpFDiQ3-IOHEZo5tP-eFxuG3VWYgj3pBYiwzkUnL2rCej35avyClkcY9VaEXeD_crN069firR3wj1pkkGX8IOlrgD35LEobDFtX0WbZC68iSlC7sXGqeFyltdP7lKVf97tRMF980eNFIyt3HHftzIgGBramqq0LRTVbCAV7YZEUyOn0q_TfgxX4h1Zh5PeR-sSIgZ032-FvdLgwwksHqXNUwx_dDY3P8l03wVb-1lswVmb85qkrcfR8Sq4bkoDdk5sOjlLYmedHYOHtZmCGnGpVHwFr--0L06NQ0qxPRyO4_KbhsAe3GUsLg6WZOJTNZ0dZau8iHw11rUbuYMxJFz1dA7ElzB3oalrDKQAoughRhFbsnejjGp6jU';

  // VEX IQ Program ID (usually 41 for VEX IQ, verify via API or documentation)
  static const int vexIqProgramId = 41;

  // Current Season ID (from API response: 196 for 2025-2026 Mix & Match)
  // This is critical to filter out events from previous years with same dates.
  static const int currentSeasonId = 196;

  // RoboStem API (for World Skills)
  static const String roboStemBaseUrl = 'https://api.robostem-api.org';
  static const String roboStemApiKey =
      '6ab1d415d0447945ff6e989a081fba659b7f2eb34ab3a2a07451a365aa6114f7';
}
