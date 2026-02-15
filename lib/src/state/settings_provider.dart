import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/constants.dart';
import 'package:roboscout_iq/src/services/secure_storage_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  final int primarySeasonId;
  final String? robotEventsApiKey;
  final String? roboStemApiKey;

  SettingsState({
    required this.themeMode,
    required this.primarySeasonId,
    this.robotEventsApiKey,
    this.roboStemApiKey,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? primarySeasonId,
    String? robotEventsApiKey,
    String? roboStemApiKey,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      primarySeasonId: primarySeasonId ?? this.primarySeasonId,
      robotEventsApiKey: robotEventsApiKey ?? this.robotEventsApiKey,
      roboStemApiKey: roboStemApiKey ?? this.roboStemApiKey,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Box _settingsBox;
  final SecureStorageService _secureStorage;

  SettingsNotifier(this._settingsBox, this._secureStorage)
      : super(SettingsState(
          themeMode: ThemeMode.system,
          primarySeasonId: AppConstants.currentSeasonId,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeIndex =
        _settingsBox.get('theme_mode', defaultValue: ThemeMode.system.index);
    final seasonId = _settingsBox.get('season_id',
        defaultValue: AppConstants.currentSeasonId);

    final reKey = await _secureStorage.getApiKey();
    final rsKey = await _secureStorage.getRoboStemApiKey();

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      primarySeasonId: seasonId,
      robotEventsApiKey: reKey,
      roboStemApiKey: rsKey,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _settingsBox.put('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setSeason(int seasonId) async {
    await _settingsBox.put('season_id', seasonId);
    state = state.copyWith(primarySeasonId: seasonId);
  }

  Future<void> setRobotEventsApiKey(String key) async {
    if (key.isEmpty) {
      await _secureStorage.deleteApiKey();
      state = state.copyWith(robotEventsApiKey: null);
    } else {
      await _secureStorage.saveApiKey(key);
      state = state.copyWith(robotEventsApiKey: key);
    }
  }

  Future<void> setRoboStemApiKey(String key) async {
    if (key.isEmpty) {
      await _secureStorage.deleteRoboStemApiKey();
      state = state.copyWith(roboStemApiKey: null);
    } else {
      await _secureStorage.saveRoboStemApiKey(key);
      state = state.copyWith(roboStemApiKey: key);
    }
  }
}
