import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class EventsRepository {
  final ApiClient _apiClient;
  final LocalDbService _localDb;

  EventsRepository(this._apiClient, this._localDb);

  Future<void> basicSync() async {
    // Fetch in two batches to ensure we cover "around now" correctly
    try {
      final now = DateTime.now();
      // Strip time for clean API queries
      final today = DateTime(now.year, now.month, now.day);
      
      // Batch 1: Past (Last 3 months to ensure coverage)
      // "Rest that happened before it" -> probably wants to see recent season history
      final pastEvents = await _apiClient.getEvents(
        from: today.subtract(const Duration(days: 90)),
        to: today.add(const Duration(days: 1)), // Include today in "Past" query safely
        limit: 250,
      );
      
      // Batch 2: Future (Next 6 months)
      final futureEvents = await _apiClient.getEvents(
        from: today,
        to: today.add(const Duration(days: 180)),
        limit: 250,
      );

      print('DEBUG: Sync fetched ${pastEvents.length} past and ${futureEvents.length} future events.');

      final allEvents = {...{for (var e in pastEvents) e.id: e}, ...{for (var e in futureEvents) e.id: e}};
      
      await _localDb.eventsBox.putAll(allEvents);
    } catch (e) {
      // Log error or rethrow if manual sync
      print('Sync failed: $e');
    }
  }

  // Watch all events from local DB
  ValueListenable<Box<Event>> watchEvents() {
    return _localDb.eventsBox.listenable();
  }

  List<Event> getAllEvents() {
    return _localDb.eventsBox.values.toList();
  }

  Future<List<Event>> searchEvents(String name) async {
    return _apiClient.searchEvents(name: name, limit: 20);
  }

  // For week-based view, we might need a specific range fetch
  Future<List<Event>> fetchEventsForRange(DateTime start, DateTime end) async {
    return _apiClient.searchEvents(start: start, end: end, limit: 100);
  }

  Future<List<Map<String, dynamic>>> getEventRankings(int eventId) async {
    return _apiClient.getEventRankings(eventId);
  }

  Future<List<Map<String, dynamic>>> getEventAwards(int eventId) async {
    return _apiClient.getEventAwards(eventId);
  }
}
