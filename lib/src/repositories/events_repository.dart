import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

import 'package:roboscout_iq/src/state/settings_provider.dart';

class EventsRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;
  final SettingsState _settings;

  // In-memory cache for event details
  final Map<int, List<Map<String, dynamic>>> _rankingsCache = {};
  final Map<int, List<Map<String, dynamic>>> _finalistRankingsCache = {};
  final Map<int, List<Map<String, dynamic>>> _skillsCache = {};
  final Map<int, List<Map<String, dynamic>>> _awardsCache = {};

  EventsRepository(this._apiClient, this._localDb, this._settings);

  /// Syncs events from the RobotEvents API into local Hive storage.
  /// Uses 3 targeted date range queries for efficient fetching.
  Future<void> basicSync() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      debugPrint('DEBUG basicSync: Starting. Today=$today');

      // Batch 1: Recent + Near Future (-14 days to +30 days)
      final immediateEvents = await _apiClient.getEvents(
        from: today.subtract(const Duration(days: 14)),
        to: today.add(const Duration(days: 30)),
        seasonId: _settings.primarySeasonId,
      );

      // Batch 2: Extended Future (+30 days to +120 days)
      final futureEvents = await _apiClient.getEvents(
        from: today.add(const Duration(days: 30)),
        to: today.add(const Duration(days: 120)),
        seasonId: _settings.primarySeasonId,
      );

      // Batch 3: Full Past Season (-180 days to -14 days)
      final pastEvents = await _apiClient.getEvents(
        from: today.subtract(const Duration(days: 180)),
        to: today.subtract(const Duration(days: 14)),
        seasonId: _settings.primarySeasonId,
      );

      debugPrint(
          'DEBUG basicSync: Fetched ${immediateEvents.length} immediate, ${futureEvents.length} future, ${pastEvents.length} past events.');

      // Merge all events by ID
      final allEvents = {
        ...{for (var e in immediateEvents) e.id: e},
        ...{for (var e in futureEvents) e.id: e},
        ...{for (var e in pastEvents) e.id: e},
      };

      await _localDb.eventsBox.putAll(allEvents);
      debugPrint(
          'DEBUG basicSync: Stored ${allEvents.length} events in Hive. Box now has ${_localDb.eventsBox.length} entries.');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  // Watch all events from local DB
  ValueListenable<Box<Event>> watchEvents() {
    return _localDb.eventsBox.listenable();
  }

  List<Event> getAllEvents() {
    return _localDb.eventsBox.values.toList();
  }

  Future<Event?> getEventById(int id) async {
    if (_localDb.eventsBox.containsKey(id)) {
      return _localDb.eventsBox.get(id);
    }
    try {
      final event = await _apiClient.getEvent(id);
      await _localDb.eventsBox.put(id, event);
      return event;
    } catch (e) {
      debugPrint('Error getting event $id: $e');
      return null;
    }
  }

  Future<List<Event>> searchEvents(String name) async {
    return _apiClient.searchEvents(name: name);
  }

  // For week-based view, we might need a specific range fetch
  Future<List<Event>> fetchEventsForRange(DateTime start, DateTime end) async {
    return _apiClient.searchEvents(start: start, end: end);
  }

  Future<List<Map<String, dynamic>>> getEventRankings(int eventId) async {
    if (_rankingsCache.containsKey(eventId)) {
      return _rankingsCache[eventId]!;
    }
    final data = await _apiClient.getEventRankings(eventId);
    _rankingsCache[eventId] = data;
    return data;
  }

  Future<List<Map<String, dynamic>>> getFinalistRankings(int eventId) async {
    if (_finalistRankingsCache.containsKey(eventId)) {
      return _finalistRankingsCache[eventId]!;
    }
    final data = await _apiClient.getFinalistRankings(eventId);
    _finalistRankingsCache[eventId] = data;
    return data;
  }

  Future<List<Event>> getEventsBySkus(List<String> skus) async {
    if (skus.isEmpty) return [];

    final localEvents = <Event>[];
    final missingSkus = <String>[];
    final allLocal = _localDb.eventsBox.values;

    for (var sku in skus) {
      try {
        final event = allLocal.firstWhere((e) => e.sku == sku);
        localEvents.add(event);
      } catch (_) {
        missingSkus.add(sku);
      }
    }

    if (missingSkus.isNotEmpty) {
      try {
        final remoteEvents = await _apiClient.searchEvents(skus: missingSkus);
        await _localDb.eventsBox.putAll({for (var e in remoteEvents) e.id: e});
        localEvents.addAll(remoteEvents);
      } catch (e) {
        debugPrint('Error fetching missing events via SKUs: $e');
      }
    }

    return localEvents;
  }

  /// Synchronously gets events from local DB by SKUs.
  /// Useful for instant display in Favorites.
  List<Event> getLocalEvents(List<String> skus) {
    if (skus.isEmpty) return [];
    final allLocal = _localDb.eventsBox.values;
    final events = <Event>[];
    for (var sku in skus) {
      try {
        final event = allLocal.firstWhere((e) => e.sku == sku);
        events.add(event);
      } catch (_) {
        // Missing locally, ignore for now or handle elsewhere
      }
    }
    return events;
  }

  Future<List<Map<String, dynamic>>> getEventAwards(int eventId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _awardsCache.containsKey(eventId)) {
      return _awardsCache[eventId]!;
    }
    final data = await _apiClient.getEventAwards(eventId);
    _awardsCache[eventId] = data;
    return data;
  }

  void clearAwardsCache(int eventId) => _awardsCache.remove(eventId);

  Future<List<Map<String, dynamic>>> getEventSkills(int eventId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _skillsCache.containsKey(eventId)) {
      return _skillsCache[eventId]!;
    }
    final data = await _apiClient.getEventSkills(eventId);
    _skillsCache[eventId] = data;
    return data;
  }

  void clearSkillsCache(int eventId) => _skillsCache.remove(eventId);

  void clearRankingsCache(int eventId) {
    _rankingsCache.remove(eventId);
    _finalistRankingsCache.remove(eventId);
  }
}
