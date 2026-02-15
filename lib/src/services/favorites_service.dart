import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final favoritesServiceProvider = Provider((ref) => FavoritesService());

class FavoritesService extends ChangeNotifier {
  static const String _boxName = 'favorites_box';
  static const String _favoriteTeamsKey = 'favorite_teams';
  static const String _favoriteEventsKey = 'favorite_events';

  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    notifyListeners();
  }

  // Teams
  List<String> getFavoriteTeams() {
    return _box?.get(_favoriteTeamsKey,
            defaultValue: <String>[])?.cast<String>() ??
        [];
  }

  Future<void> addFavoriteTeam(String teamNumber) async {
    final current = List<String>.from(getFavoriteTeams());
    if (!current.contains(teamNumber)) {
      current.add(teamNumber);
      await _box?.put(_favoriteTeamsKey, current);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteTeam(String teamNumber) async {
    final current = List<String>.from(getFavoriteTeams());
    if (current.contains(teamNumber)) {
      current.remove(teamNumber);
      await _box?.put(_favoriteTeamsKey, current);
      notifyListeners();
    }
  }

  bool isTeamFavorite(String teamNumber) {
    return getFavoriteTeams().contains(teamNumber);
  }

  // Events
  List<String> getFavoriteEvents() {
    return _box?.get(_favoriteEventsKey,
            defaultValue: <String>[])?.cast<String>() ??
        [];
  }

  Future<void> addFavoriteEvent(String eventSku) async {
    final current = List<String>.from(getFavoriteEvents());
    if (!current.contains(eventSku)) {
      current.add(eventSku);
      await _box?.put(_favoriteEventsKey, current);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteEvent(String eventSku) async {
    final current = List<String>.from(getFavoriteEvents());
    if (current.contains(eventSku)) {
      current.remove(eventSku);
      await _box?.put(_favoriteEventsKey, current);
      notifyListeners();
    }
  }

  bool isEventFavorite(String eventSku) {
    return getFavoriteEvents().contains(eventSku);
  }
}
