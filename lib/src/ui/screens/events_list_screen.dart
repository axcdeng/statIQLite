import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/favorites_screen.dart';
import 'package:roboscout_iq/src/ui/screens/resources_screen.dart';
import 'package:roboscout_iq/src/ui/screens/settings_screen.dart';
import 'package:roboscout_iq/src/ui/screens/team_lookup_screen.dart';
import 'package:roboscout_iq/src/ui/screens/world_skills_screen.dart';

class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  final List<Widget> _screens = [
    const FavoritesScreen(),
    const WorldSkillsScreen(),
    const TeamLookupScreen(),
    const ResourcesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        activeColor: primaryColor,
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.star_fill)),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar_fill)),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.search)),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_fill)),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings)),
        ],
      ),
    );
  }
}

class EventsListView extends ConsumerStatefulWidget {
  final bool showNavigationBar;
  const EventsListView({super.key, this.showNavigationBar = true});

  @override
  ConsumerState<EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends ConsumerState<EventsListView> {
  final TextEditingController _searchController = TextEditingController();
  List<DateTime> _weeks = [];
  final Set<String> _expandedWeeks = {};

  // Cached groupings — rebuilt only when Hive data changes
  Map<int, List<Event>> _weekEventsCache = {};
  int _lastEventCount = -1;

  @override
  void initState() {
    super.initState();
    _initializeWeeks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsRepositoryProvider).basicSync();
    });
  }

  void _initializeWeeks() {
    final now = DateTime.now();
    final currentWeekday = now.weekday == 7 ? 0 : now.weekday;
    final startOfCurrentWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: currentWeekday));

    final seasonStart = DateTime(2025, 8, 18);

    _weeks = [];
    for (int i = 4; i >= 0; i--) {
      _weeks.add(startOfCurrentWeek.add(Duration(days: 7 * i)));
    }
    var pastWeek = startOfCurrentWeek.subtract(const Duration(days: 7));
    while (!pastWeek.isBefore(seasonStart)) {
      _weeks.add(pastWeek);
      pastWeek = pastWeek.subtract(const Duration(days: 7));
    }
  }

  void _loadFuture() {
    if (_weeks.isNotEmpty) {
      var first = _weeks.first;
      for (int i = 0; i < 3; i++) {
        first = first.add(const Duration(days: 7));
        _weeks.insert(0, first);
      }
      _lastEventCount = -1; // Force re-group
      setState(() {});
    }
  }

  /// Group all events by week index. Only recompute when event count changes.
  void _rebuildWeekCache(List<Event> allEvents) {
    if (allEvents.length == _lastEventCount) return;
    _lastEventCount = allEvents.length;

    _weekEventsCache = {};
    for (final event in allEvents) {
      final eDate = DateTime(
          event.startDate.year, event.startDate.month, event.startDate.day);
      for (int i = 0; i < _weeks.length; i++) {
        final wStart = _weeks[i];
        final wEnd = wStart.add(const Duration(days: 6));
        if (!eDate.isBefore(wStart) && !eDate.isAfter(wEnd)) {
          _weekEventsCache.putIfAbsent(i, () => []).add(event);
          break;
        }
      }
    }
    for (final list in _weekEventsCache.values) {
      list.sort((a, b) => b.startDate.compareTo(a.startDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsRepo = ref.watch(eventsRepositoryProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final content = SafeArea(
      child: ValueListenableBuilder<Box<Event>>(
        valueListenable: eventsRepo.watchEvents(),
        builder: (context, box, _) {
          final allEvents = box.values.toList();
          _rebuildWeekCache(allEvents);

          final searchQuery = _searchController.text.toLowerCase();

          // Build filtered week cache if searching
          Map<int, List<Event>> displayCache;
          if (searchQuery.isNotEmpty) {
            displayCache = {};
            for (final entry in _weekEventsCache.entries) {
              final filtered = entry.value
                  .where((e) =>
                      e.name.toLowerCase().contains(searchQuery) ||
                      (e.sku?.toLowerCase().contains(searchQuery) ?? false))
                  .toList();
              if (filtered.isNotEmpty) {
                displayCache[entry.key] = filtered;
              }
            }
          } else {
            displayCache = _weekEventsCache;
          }

          final isSearching = searchQuery.isNotEmpty;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // "Load Future" button - hide during search
                    if (!isSearching)
                      SliverToBoxAdapter(
                        child: CupertinoButton(
                          onPressed: _loadFuture,
                          child: Text('Load 3 More Weeks (Future)',
                              style: TextStyle(color: primaryColor)),
                        ),
                      ),

                    // Week sections - only show weeks that have matching events
                    for (int i = 0; i < _weeks.length; i++)
                      if (displayCache.containsKey(i))
                        ..._buildWeekSection(
                            context, _weeks[i], displayCache[i] ?? []),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!widget.showNavigationBar) {
      return content;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Events'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.refresh, color: primaryColor),
          onPressed: () => eventsRepo.basicSync(),
        ),
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
      ),
      child: content,
    );
  }

  List<Widget> _buildWeekSection(
      BuildContext context, DateTime weekStart, List<Event> weekEvents) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekKey = weekStart.toIso8601String();
    final isExpanded = _expandedWeeks.contains(weekKey);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Check if this week is the current week
    final now = DateTime.now();
    final isCurrentWeek = !now.isBefore(weekStart) &&
        !now.isAfter(weekEnd.add(const Duration(days: 1)));

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Column(
            children: [
              // Week Header Card
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedWeeks.remove(weekKey);
                    } else {
                      _expandedWeeks.add(weekKey);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemGroupedBackground
                        .resolveFrom(context),
                    borderRadius: isExpanded
                        ? const BorderRadius.vertical(top: Radius.circular(12))
                        : BorderRadius.circular(12),
                    border: isCurrentWeek
                        ? Border.all(
                            color: primaryColor.withOpacity(0.4), width: 1)
                        : null,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Accent bar
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isCurrentWeek
                                  ? [primaryColor, CupertinoColors.systemBlue]
                                  : [
                                      CupertinoColors.systemGrey4,
                                      CupertinoColors.systemGrey5
                                    ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  size: 20,
                                  color: isCurrentWeek
                                      ? primaryColor
                                      : CupertinoColors.systemGrey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${weekStart.month}/${weekStart.day} – ${weekEnd.month}/${weekEnd.day}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: isCurrentWeek
                                                  ? CupertinoColors.label
                                                      .resolveFrom(context)
                                                  : CupertinoColors
                                                      .secondaryLabel
                                                      .resolveFrom(context),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          if (isCurrentWeek) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: primaryColor
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text('NOW',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: primaryColor,
                                                      letterSpacing: 0.5)),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Event count badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrentWeek
                                        ? primaryColor.withOpacity(0.15)
                                        : CupertinoColors
                                            .tertiarySystemGroupedBackground
                                            .resolveFrom(context),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${weekEvents.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isCurrentWeek
                                          ? primaryColor
                                          : CupertinoColors.secondaryLabel
                                              .resolveFrom(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? CupertinoIcons.chevron_down
                                      : CupertinoIcons.chevron_right,
                                  size: 13,
                                  color: CupertinoColors.systemGrey
                                      .resolveFrom(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Expanded Events
              if (isExpanded)
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemGroupedBackground
                        .resolveFrom(context),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                  ),
                  child: Column(
                    children: [
                      const Divider(
                          height: 1,
                          color: CupertinoColors.separator,
                          indent: 20,
                          endIndent: 20),
                      ...weekEvents
                          .map((event) => _buildEventTile(context, event)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildEventTile(BuildContext context, Event event) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final dateStr =
        '${event.startDate.month}/${event.startDate.day}/${event.startDate.year}';

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(AppRoutes.eventDetail, arguments: event);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.location_solid, size: 14, color: primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: CupertinoColors.label.resolveFrom(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${event.location ?? 'Unknown'}  •  $dateStr',
                    style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right,
                size: 12, color: CupertinoColors.systemGrey2),
          ],
        ),
      ),
    );
  }
}
