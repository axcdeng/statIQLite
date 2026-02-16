import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

/// Minimal data needed to render a week section.
@immutable
class WeekSection {
  final DateTime weekStart;
  final List<Event> events;

  const WeekSection({
    required this.weekStart,
    required this.events,
  });
}

/// Consolidated filter state.
@immutable
class EventFilters {
  final String searchQuery;
  final List<String> countries;
  final List<String> regions;
  final List<String> grades;
  final List<String> types;

  const EventFilters({
    this.searchQuery = '',
    this.countries = const [],
    this.regions = const [],
    this.grades = const [],
    this.types = const [],
  });

  EventFilters copyWith({
    String? searchQuery,
    List<String>? countries,
    List<String>? regions,
    List<String>? grades,
    List<String>? types,
  }) {
    return EventFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      countries: countries ?? this.countries,
      regions: regions ?? this.regions,
      grades: grades ?? this.grades,
      types: types ?? this.types,
    );
  }

  /// Signature for caching.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventFilters &&
        other.searchQuery == searchQuery &&
        listEquals(other.countries, countries) &&
        listEquals(other.regions, regions) &&
        listEquals(other.grades, grades) &&
        listEquals(other.types, types);
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        Object.hashAll(countries),
        Object.hashAll(regions),
        Object.hashAll(grades),
        Object.hashAll(types),
      );
}

/// State for the EventsListController.
@immutable
class EventsListState {
  final List<DateTime> weeks;
  final Map<int, List<Event>> weekCache; // Key is index in `weeks`
  final EventFilters filters;
  final bool isIndexing;

  const EventsListState({
    this.weeks = const [],
    this.weekCache = const {},
    this.filters = const EventFilters(),
    this.isIndexing = false,
  });

  EventsListState copyWith({
    List<DateTime>? weeks,
    Map<int, List<Event>>? weekCache,
    EventFilters? filters,
    bool? isIndexing,
  }) {
    return EventsListState(
      weeks: weeks ?? this.weeks,
      weekCache: weekCache ?? this.weekCache,
      filters: filters ?? this.filters,
      isIndexing: isIndexing ?? this.isIndexing,
    );
  }
}

// -----------------------------------------------------------------------------
// Controller
// -----------------------------------------------------------------------------

class EventsListController extends StateNotifier<EventsListState> {
  final Ref _ref;

  // Debounce timer for search
  // Using a simpler approach than `Timer` to avoid import conflicts
  // or disposal issues. We might just delay search application.

  EventsListController(this._ref) : super(const EventsListState()) {
    _initializeWeeks();
    // Listen to repository changes
    final eventsRepo = _ref.read(eventsRepositoryProvider);
    eventsRepo.watchEvents().addListener(_onDataChanged);
    // Initial compute
    _recompute();
  }

  void _onDataChanged() {
    // Recompute when underlying data changes
    _recompute();
  }

  @override
  void dispose() {
    final eventsRepo = _ref.read(eventsRepositoryProvider);
    eventsRepo.watchEvents().removeListener(_onDataChanged);
    super.dispose();
  }

  void _initializeWeeks() {
    final now = DateTime.now();
    final currentWeekday = now.weekday == 7 ? 0 : now.weekday;
    final startOfCurrentWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: currentWeekday));

    final seasonStart = DateTime(2025, 8, 18);

    List<DateTime> initialWeeks = [];
    for (int i = 4; i >= 0; i--) {
      initialWeeks.add(startOfCurrentWeek.add(Duration(days: 7 * i)));
    }
    var pastWeek = startOfCurrentWeek.subtract(const Duration(days: 7));
    while (!pastWeek.isBefore(seasonStart)) {
      initialWeeks.add(pastWeek);
      pastWeek = pastWeek.subtract(const Duration(days: 7));
    }
    state = state.copyWith(weeks: initialWeeks);
  }

  void loadFutureWeeks() {
    if (state.weeks.isNotEmpty) {
      var first = state.weeks.first;
      final newWeeks = List<DateTime>.from(state.weeks);
      for (int i = 0; i < 3; i++) {
        first = first.add(const Duration(days: 7));
        newWeeks.insert(0, first);
      }
      state = state.copyWith(weeks: newWeeks);
      _recompute();
    }
  }

  /// Update filters.
  void setFilters(EventFilters newFilters) {
    if (state.filters == newFilters) return;
    state = state.copyWith(filters: newFilters);
    _recompute();
  }

  /// Update search query (debouncing should happen in UI before calling this if desired,
  /// or we can add a debouncer here. The plan suggests UI debounce, but logic here is safer).
  /// For now, we assume UI debounces or calls this directly.
  void setSearchQuery(String query) {
    if (state.filters.searchQuery == query) return;
    state = state.copyWith(
      filters: state.filters.copyWith(searchQuery: query),
    );
    _recompute();
  }

  // ---------------------------------------------------------------------------
  // Computation Logic
  // ---------------------------------------------------------------------------

  Future<void> _recompute() async {
    // Yield to let UI render loading state first
    await Future.microtask(() {});

    // 1. Get all events
    final eventsRepo = _ref.read(eventsRepositoryProvider);
    final allEvents = eventsRepo.getAllEvents(); // Synchronous Hive read

    // 2. Prepare params for isolation
    final params = _ComputeParams(
      allEvents: allEvents,
      weeks: state.weeks,
      filters: state.filters,
    );

    // 3. Mark indexing (optional UI feedback)
    // state = state.copyWith(isIndexing: true);

    // 4. Compute
    // Threshold for using isolate
    Map<int, List<Event>> resultMap;
    if (allEvents.length > 500) {
      resultMap = await compute(_buildWeekCacheIsolated, params);
    } else {
      resultMap = _buildWeekCacheIsolated(params);
    }

    // 5. Update state
    if (mounted) {
      state = state.copyWith(
        weekCache: resultMap,
        isIndexing: false,
      );
    }
  }
}

// -----------------------------------------------------------------------------
// Isolate Logic
// -----------------------------------------------------------------------------

@immutable
class _ComputeParams {
  final List<Event> allEvents;
  final List<DateTime> weeks;
  final EventFilters filters;

  const _ComputeParams({
    required this.allEvents,
    required this.weeks,
    required this.filters,
  });
}

Map<int, List<Event>> _buildWeekCacheIsolated(_ComputeParams params) {
  final cache = <int, List<Event>>{};
  final searchQuery = params.filters.searchQuery.toLowerCase();
  final countries = params.filters.countries;
  final regions = params.filters.regions;
  final grades = params.filters.grades;
  final types = params.filters.types;

  // Pre-filter events
  final filteredEvents = params.allEvents.where((e) {
    // Search
    if (searchQuery.isNotEmpty) {
      if (!e.name.toLowerCase().contains(searchQuery) &&
          !(e.sku?.toLowerCase().contains(searchQuery) ?? false)) {
        return false;
      }
    }

    // Country
    if (countries.isNotEmpty && !countries.contains(e.country)) {
      return false;
    }

    // Region
    if (regions.isNotEmpty) {
      final region = e.region ?? '';
      bool regionMatch = false;
      for (final sel in regions) {
        if (region.isNotEmpty &&
            (sel == region ||
                sel.startsWith(region) ||
                region.startsWith(sel))) {
          regionMatch = true;
          break;
        }
      }
      if (!regionMatch) return false;
    }

    // Grade
    if (grades.isNotEmpty) {
      final eGrades = e.grades ?? [];
      bool gradeMatch = false;
      // Exact match
      if (eGrades.any((g) => grades.contains(g))) {
        gradeMatch = true;
      } else {
        // Fallback: Infer from name
        final name = e.name.toLowerCase();
        for (final sel in grades) {
          if (sel == 'Middle School') {
            if (name.contains('middle school') ||
                name.contains(' ms') ||
                name.contains('_ms') ||
                name.contains('-ms')) {
              gradeMatch = true;
              break;
            }
          } else if (sel == 'Elementary School') {
            if (name.contains('elementary school') ||
                name.contains(' es') ||
                name.contains('_es') ||
                name.contains('-es')) {
              gradeMatch = true;
              break;
            }
          }
        }
      }
      if (!gradeMatch) return false;
    }

    // Type
    if (types.isNotEmpty) {
      final mappedSelected =
          types.map((t) => t == 'State' ? 'Regional' : t).toList();
      if (!mappedSelected.contains(e.level)) {
        return false;
      }
    }

    return true;
  }).toList();

  // Group by week
  for (final event in filteredEvents) {
    final eDate = DateTime(
        event.startDate.year, event.startDate.month, event.startDate.day);
    for (int i = 0; i < params.weeks.length; i++) {
      final wStart = params.weeks[i];
      final wEnd = wStart.add(const Duration(days: 6));
      if (!eDate.isBefore(wStart) && !eDate.isAfter(wEnd)) {
        cache.putIfAbsent(i, () => []).add(event);
        break;
      }
    }
  }

  // Sort
  for (final list in cache.values) {
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  return cache;
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final eventsListControllerProvider =
    StateNotifierProvider<EventsListController, EventsListState>((ref) {
  return EventsListController(ref);
});
