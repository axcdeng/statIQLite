import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/favorites_screen.dart';
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
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'World Skills'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lookup'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class EventsListView extends ConsumerStatefulWidget {
  const EventsListView({super.key});

  @override
  ConsumerState<EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends ConsumerState<EventsListView> {
  final TextEditingController _searchController = TextEditingController();
  List<DateTime> _weeks = [];

  @override
  void initState() {
    super.initState();
    _initializeWeeks();
    // Trigger sync on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG: Triggering basicSync from EventsListView');
      ref.read(eventsRepositoryProvider).basicSync();
    });
  }

  void _initializeWeeks() {
    final now = DateTime.now();
    final currentWeekday = now.weekday == 7 ? 0 : now.weekday;
    final startOfCurrentWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: currentWeekday));

    print(
        'DEBUG: Init Weeks. Now: $now, StartOfCurrentWeek: $startOfCurrentWeek');

    // Future -> Past (Descending)
    _weeks = [
      startOfCurrentWeek.add(const Duration(days: 14)), // +2 weeks
      startOfCurrentWeek.add(const Duration(days: 7)), // +1 week
      startOfCurrentWeek, // Current week
    ];
    setState(() {});
  }

  void _loadFuture() {
    print('DEBUG: Loading Future');
    setState(() {
      if (_weeks.isNotEmpty) {
        var first = _weeks.first;
        for (int i = 0; i < 3; i++) {
          first = first.add(const Duration(days: 7));
          _weeks.insert(0, first);
        }
      }
    });
  }

  void _loadPast() {
    print('DEBUG: Loading Past');
    setState(() {
      if (_weeks.isNotEmpty) {
        final last = _weeks.last;
        _weeks.add(last.subtract(const Duration(days: 7)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsRepo = ref.watch(eventsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('DEBUG: Manual Refresh Clicked');
              eventsRepo.basicSync();
            },
          )
        ],
      ),
      body: ValueListenableBuilder<Box<Event>>(
        valueListenable: eventsRepo.watchEvents(),
        builder: (context, box, _) {
          final allEvents = box.values.toList();
          final searchQuery = _searchController.text.toLowerCase();

          print('DEBUG: Total Events in Store: ${allEvents.length}');
          if (allEvents.isNotEmpty) {
            print('DEBUG: Sample Event Date: ${allEvents.first.startDate}');
          }

          if (searchQuery.isNotEmpty) {
            final filtered = allEvents
                .where((e) =>
                    e.name.toLowerCase().contains(searchQuery) ||
                    (e.sku?.toLowerCase().contains(searchQuery) ?? false))
                .toList();

            filtered.sort(
                (a, b) => b.startDate.compareTo(a.startDate)); // Descending

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildEventTile(context, filtered[index]);
              },
            );
          }

          // Week Groups
          return ListView.builder(
            itemCount: _weeks.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return TextButton(
                    onPressed: _loadFuture,
                    child: const Text('Load 3 More Weeks (Future)'));
              }

              if (index == _weeks.length + 1) {
                return TextButton(
                    onPressed: _loadPast, child: const Text('Load Past Week'));
              }

              final weekStart = _weeks[index - 1];
              final weekEnd = weekStart
                  .add(const Duration(days: 6, hours: 23, minutes: 59));

              final weekEvents = allEvents
                  .where((e) =>
                      e.startDate.isAfter(
                          weekStart.subtract(const Duration(seconds: 1))) &&
                      e.startDate.isBefore(weekEnd))
                  .toList();

              // Sort events within week (Descending? Or Ascending?)
              // Generally by importance or date. Descending (latest first) is often preferred.
              weekEvents.sort((a, b) => b.startDate.compareTo(a.startDate));

              if (weekEvents.isNotEmpty) {
                print(
                    'DEBUG: Week ${weekStart.toString().split(' ')[0]} has ${weekEvents.length} events');
              }

              return ExpansionTile(
                key: PageStorageKey(weekStart.toIso8601String()),
                initiallyExpanded: weekEvents.isNotEmpty,
                title: Text(
                    '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}'),
                subtitle: Text('${weekEvents.length} Events'),
                children:
                    weekEvents.map((e) => _buildEventTile(context, e)).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, Event event) {
    return ListTile(
      title: Text(event.name),
      subtitle: Text(
          '${event.location ?? 'Unknown'} • ${event.startDate.toString().split(' ')[0]}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context)
            .pushNamed(AppRoutes.eventDetail, arguments: event);
      },
    );
  }
}
