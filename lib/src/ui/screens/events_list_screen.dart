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

const List<String> _allEventRegions = [
  'Afghanistan',
  'Alabama',
  'Alaska',
  'Albania',
  'Alberta/Saskatchewan',
  'Algeria',
  'American Samoa',
  'Andorra',
  'Angola',
  'Argentina',
  'Arizona',
  'Arkansas',
  'Armenia',
  'Aruba',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bahamas',
  'Bahrain',
  'Bangladesh',
  'Barbados',
  'Belarus',
  'Belgium',
  'Belize',
  'Benin',
  'Bermuda',
  'Bhutan',
  'Bolivia',
  'Bosnia and Herzegovina',
  'Botswana',
  'Brazil',
  'British Columbia',
  'British Columbia (BC)',
  'Brunei',
  'Bulgaria',
  'Burkina Faso',
  'Burundi',
  'California - North',
  'California - South',
  'Cambodia',
  'Cameroon',
  'Canada',
  'Cayman Islands',
  'Central African Republic',
  'Chad',
  'Chile',
  'Chinese Taipei',
  'Colombia',
  'Colorado',
  'Connecticut',
  'Cook Islands',
  'Costa Rica',
  'Croatia',
  'Cuba',
  'Cyprus',
  'Czech Republic',
  'Côte d’Ivoire',
  'Delaware',
  'Delmarva',
  'Democratic Republic of the Congo',
  'Denmark',
  'District of Columbia',
  'Djibouti',
  'Dominican Republic',
  'East China',
  'East Timor',
  'Ecuador',
  'Egypt',
  'El Salvador',
  'Equatorial Guinea',
  'Eritrea',
  'Estonia',
  'Eswatini',
  'Ethiopia',
  'Falkland Islands',
  'Fiji',
  'Finland',
  'Florida - North/Central',
  'Florida - South',
  'France',
  'French Guiana',
  'French Southern and Antarctic Territories',
  'Gabon',
  'Gambia',
  'Georgia',
  'Georgia- Country',
  'Germany',
  'Ghana',
  'Greece',
  'Greenland',
  'Guam',
  'Guatemala',
  'Guinea',
  'Guinea-Bissau',
  'Guyana',
  'Haiti',
  'Hawaii',
  'Honduras',
  'Hong Kong',
  'Hungary',
  'Iceland',
  'Idaho',
  'Illinois',
  'India',
  'Indiana - Region 1 - North',
  'Indiana - Region 2 - Central',
  'Indiana - Region 3 - South',
  'Indonesia',
  'Iowa',
  'Iran',
  'Iraq',
  'Ireland',
  'Israel',
  'Italy',
  'Jamaica',
  'Japan',
  'Jordan',
  'Kansas',
  'Kazakhstan',
  'Kentucky',
  'Kenya',
  'Kosovo',
  'Kuwait',
  'Kyrgyzstan',
  'Laos',
  'Latvia',
  'Lebanon',
  'Lesotho',
  'Liberia',
  'Libya',
  'Lithuania',
  'Louisiana',
  'Luxembourg',
  'Macau',
  'Macedonia',
  'Madagascar',
  'Maine',
  'Malawi',
  'Malaysia',
  'Mali',
  'Manitoba',
  'Maryland',
  'Massachusetts',
  'Mauritania',
  'Mexico',
  'Michigan',
  'Middle China',
  'Minnesota',
  'Mississippi',
  'Missouri',
  'Moldova',
  'Mongolia',
  'Montana',
  'Montenegro',
  'Morocco',
  'Mozambique',
  'Myanmar',
  'Namibia',
  'Nebraska',
  'Nepal',
  'Netherlands',
  'Nevada',
  'New Brunswick/Nova Scotia/Prince Edward Island',
  'New Caledonia',
  'New Hampshire/Vermont',
  'New Jersey',
  'New Mexico',
  'New York-North',
  'New York-South',
  'New Zealand',
  'Newfoundland and Labrador',
  'Nicaragua',
  'Niger',
  'Nigeria',
  'North Carolina',
  'North China',
  'North Dakota',
  'North Korea',
  'Northern Mariana Islands',
  'Norway',
  'Ohio',
  'Oklahoma',
  'Oman',
  'Ontario',
  'Oregon',
  'Pakistan',
  'Palestinian Territory',
  'Panama',
  'Papua New Guinea',
  'Paraguay',
  'Pennsylvania - East',
  'Pennsylvania - West',
  'Peru',
  'Philippines',
  'Poland',
  'Portugal',
  'Puerto Rico',
  'Qatar',
  'Quebec',
  'Republic of Congo',
  'Rhode Island',
  'Romania',
  'Russia',
  'Rwanda',
  'Saudi Arabia',
  'Senegal',
  'Serbia',
  'Sierra Leone',
  'Singapore',
  'Slovakia',
  'Slovenia',
  'Solomon Islands',
  'Somalia',
  'South Africa',
  'South Carolina',
  'South China',
  'South Dakota',
  'South Korea',
  'South Sudan',
  'Southern New England',
  'Spain',
  'Sri Lanka',
  'Sudan',
  'Suriname',
  'Sweden',
  'Switzerland',
  'Syria',
  'Tajikistan',
  'Tanzania',
  'Tennessee',
  'Texas - Region 1',
  'Texas - Region 2',
  'Texas - Region 3',
  'Texas - Region 4',
  'Texas - Region 5',
  'Texas - Region 6',
  'Thailand',
  'Togo',
  'Trinidad and Tobago',
  'Tunisia',
  'Turkmenistan',
  'Turks and Caicos Islands',
  'Türkiye',
  'U.S. Virgin Islands',
  'Uganda',
  'Ukraine',
  'Unassigned',
  'United Arab Emirates',
  'United Kingdom',
  'Uruguay',
  'Utah',
  'Uzbekistan',
  'Vancouver Island (BC)',
  'Vanuatu',
  'Venezuela',
  'Vietnam',
  'Virginia',
  'Washington',
  'West China',
  'West Virginia',
  'Western Sahara',
  'Wisconsin',
  'Wyoming',
  'Yemen',
  'Zambia',
  'Zimbabwe',
];

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
  String? _lastSearchQuery;

  // Filter State
  List<String> _selectedCountries = [];
  List<String> _selectedRegions = [];
  List<String> _selectedGrades = [];
  List<String> _selectedTypes = [];

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

  /// Group all events by week index. Only recompute when event count or filters change.
  void _rebuildWeekCache(List<Event> allEvents, String searchQuery) {
    if (allEvents.length == _lastEventCount &&
        searchQuery == _lastSearchQuery) {
      return;
    }
    _lastEventCount = allEvents.length;
    _lastSearchQuery = searchQuery;

    _weekEventsCache = {};

    // Pre-filter events based on search AND the new filters
    final filteredEvents = allEvents.where((e) {
      // Search query
      if (searchQuery.isNotEmpty) {
        if (!e.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
            !(e.sku?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false)) {
          return false;
        }
      }

      // Country filter
      if (_selectedCountries.isNotEmpty &&
          !_selectedCountries.contains(e.country)) {
        return false;
      }

      // Region filter
      if (_selectedRegions.isNotEmpty) {
        final region = e.region ?? '';
        bool regionMatch = false;
        for (final sel in _selectedRegions) {
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

      // Grade filter
      if (_selectedGrades.isNotEmpty) {
        final grades = e.grades ?? [];
        bool gradeMatch = false;

        // Try exact match first
        if (grades.any((g) => _selectedGrades.contains(g))) {
          gradeMatch = true;
        } else {
          // Fallback: Infer from name
          final name = e.name.toLowerCase();
          for (final sel in _selectedGrades) {
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

      // Type (Level) filter
      if (_selectedTypes.isNotEmpty) {
        final mappedSelected =
            _selectedTypes.map((t) => t == 'State' ? 'Regional' : t).toList();
        if (!mappedSelected.contains(e.level)) {
          return false;
        }
      }

      return true;
    }).toList();

    for (final event in filteredEvents) {
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
          final searchQuery = _searchController.text;
          _rebuildWeekCache(allEvents, searchQuery);

          final displayCache = _weekEventsCache;
          final isSearching = searchQuery.isNotEmpty;

          // Extract unique countries and regions for filters
          final countries = allEvents
              .map((e) => e.country)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();
          final regions = allEvents
              .where((e) =>
                  _selectedCountries.isEmpty ||
                  _selectedCountries.contains(e.country))
              .map((e) => e.region)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoSearchTextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _lastEventCount = -1; // Force re-group
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          child:
                              Icon(CupertinoIcons.clock, color: primaryColor),
                          onPressed: () => _showHistory(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFilterBar(countries, regions),
                  ],
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
                            color: primaryColor.withValues(alpha: 0.4),
                            width: 1)
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
                                                color: primaryColor.withValues(
                                                    alpha: 0.15),
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
                                        ? primaryColor.withValues(alpha: 0.15)
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
        ref.read(historyServiceProvider).addEventToHistory(event);
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

  Widget _buildFilterBar(List<String> countries, List<String> regions) {
    String _getLabel(String base, List<String> selected) {
      if (selected.isEmpty) return base;
      String label = selected.first;
      if (selected.length > 1) {
        label += ' +${selected.length - 1}';
      }
      return label;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: _getLabel('Countries', _selectedCountries),
            isSelected: _selectedCountries.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Country',
              options: countries,
              currentValues: _selectedCountries,
              onSelected: (vals) {
                setState(() {
                  _selectedCountries = vals ?? [];
                  _selectedRegions = []; // Reset regions when country changes
                  _lastEventCount = -1;
                });
              },
            ),
          ),
          _buildFilterChip(
            label: _getLabel('Regions', _selectedRegions),
            isSelected: _selectedRegions.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Region',
              options: _allEventRegions,
              currentValues: _selectedRegions,
              onSelected: (vals) {
                setState(() {
                  _selectedRegions = vals ?? [];
                  _lastEventCount = -1;
                });
              },
            ),
          ),
          _buildFilterChip(
            label: _getLabel('Grades', _selectedGrades),
            isSelected: _selectedGrades.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Grade',
              options: ['Middle School', 'Elementary School'],
              currentValues: _selectedGrades,
              showSearch: false,
              showAlphaIndex: false,
              onSelected: (vals) {
                setState(() {
                  _selectedGrades = vals ?? [];
                  _lastEventCount = -1;
                });
              },
            ),
          ),
          _buildFilterChip(
            label: _getLabel('Type', _selectedTypes),
            isSelected: _selectedTypes.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Type',
              options: ['World', 'National', 'State', 'Signature', 'Other'],
              currentValues: _selectedTypes,
              showSearch: false,
              showAlphaIndex: false,
              onSelected: (vals) {
                setState(() {
                  _selectedTypes = vals ?? [];
                  _lastEventCount = -1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : CupertinoColors.systemGrey5.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : CupertinoColors.label.resolveFrom(context),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_down,
                size: 10,
                color: isSelected ? Colors.white : CupertinoColors.systemGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlphabeticalPicker({
    required String title,
    required List<String> options,
    required List<String> currentValues,
    required Function(List<String>?) onSelected,
    bool showSearch = true,
    bool showAlphaIndex = true,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _SelectionScreen(
        title: title,
        options: options,
        currentValues: currentValues,
        onSelected: onSelected,
        showSearch: showSearch,
        showAlphaIndex: showAlphaIndex,
      ),
    );
  }

  void _showHistory(BuildContext context) {
    final historyService = ref.read(historyServiceProvider);
    final recentEvents = historyService.getRecentEvents();

    if (recentEvents.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('No History'),
          content: const Text('Tap an event to see it here.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Recent Events'),
        actions: recentEvents
            .map((event) => CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .pushNamed(AppRoutes.eventDetail, arguments: event);
                  },
                  child: Text(event.name),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _SelectionScreen extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> currentValues;
  final Function(List<String>?) onSelected;
  final bool showSearch;
  final bool showAlphaIndex;

  const _SelectionScreen({
    required this.title,
    required this.options,
    required this.currentValues,
    required this.onSelected,
    this.showSearch = true,
    this.showAlphaIndex = true,
  });

  @override
  State<_SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<_SelectionScreen> {
  late List<String> _filteredOptions;
  late List<String> _tempSelected;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _alphaKeys = {};

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _tempSelected = List.from(widget.currentValues);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredOptions = widget.options
          .where((opt) =>
              opt.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAlpha(String char) {
    final key = _alphaKeys[char];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(key!.currentContext!,
          duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final Map<String, List<String>> grouped = {};
    for (var opt in _filteredOptions) {
      if (opt.isEmpty) continue;
      final firstChar = opt.substring(0, 1).toUpperCase();
      grouped.putIfAbsent(firstChar, () => []).add(opt);
    }
    final sortedAlpha = grouped.keys.toList()..sort();

    return DefaultTextStyle(
      style: TextStyle(
        color: CupertinoColors.label.resolveFrom(context),
        decoration: TextDecoration.none,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select ${widget.title}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Clear'),
                        onPressed: () {
                          setState(() {
                            _tempSelected.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Done',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          widget.onSelected(_tempSelected);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CupertinoSearchTextField(controller: _searchController),
              ),
            const SizedBox(height: 10),
            // List + Alpha Index
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: sortedAlpha.length,
                      itemBuilder: (context, index) {
                        final char = sortedAlpha[index];
                        final items = grouped[char]!;
                        _alphaKeys[char] = GlobalKey();

                        return Column(
                          key: _alphaKeys[char],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.showAlphaIndex)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                color: CupertinoColors.systemGrey6
                                    .resolveFrom(context),
                                child: Text(
                                  char,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ...items.map((item) {
                              final isSelected = _tempSelected.contains(item);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _tempSelected.remove(item);
                                    } else {
                                      _tempSelected.add(item);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: CupertinoColors.separator,
                                            width: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        item,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            decoration: TextDecoration.none),
                                      )),
                                      Icon(
                                        isSelected
                                            ? CupertinoIcons
                                                .check_mark_circled_solid
                                            : CupertinoIcons.circle,
                                        color: isSelected
                                            ? primaryColor
                                            : CupertinoColors.systemGrey4,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                  // Alpha Index Bar
                  if (widget.showAlphaIndex)
                    Container(
                      width: 30,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((char) {
                          final hasItems = grouped.containsKey(char);
                          return GestureDetector(
                            onTap: hasItems ? () => _scrollToAlpha(char) : null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                char,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  color: hasItems
                                      ? primaryColor
                                      : CupertinoColors.systemGrey4,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            // Cancel
            SafeArea(
              top: false,
              child: CupertinoButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
