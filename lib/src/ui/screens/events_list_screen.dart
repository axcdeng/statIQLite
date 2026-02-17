import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/utils/country_utils.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart';
import 'package:roboscout_iq/src/ui/screens/event_divisions_screen.dart';
import 'package:roboscout_iq/src/ui/screens/favorites_screen.dart';
import 'package:roboscout_iq/src/ui/screens/resources_screen.dart';
import 'package:roboscout_iq/src/ui/screens/settings_screen.dart';
import 'package:roboscout_iq/src/ui/screens/team_lookup_screen.dart';
import 'package:roboscout_iq/src/ui/screens/world_skills_screen.dart';
import 'package:roboscout_iq/src/state/events_list_controller.dart';
import 'dart:async';

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
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  final Set<String> _expandedWeeks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger initial sync if needed, but controller handles initial compute
      ref.read(eventsRepositoryProvider).basicSync();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      ref.read(eventsListControllerProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(eventsListControllerProvider);
    final eventsRepo = ref.watch(
        eventsRepositoryProvider); // Keep watching repo for sync status/updates if needed
    final primaryColor = Theme.of(context).colorScheme.primary;

    final weeks = listState.weeks;
    final displayCache = listState.weekCache;
    final filters = listState.filters;
    final isSearching = filters.searchQuery.isNotEmpty;

    final populatedWeekIndices = displayCache.keys.toList()..sort();

    final content = SafeArea(
      child: Column(
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
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: Icon(CupertinoIcons.clock, color: primaryColor),
                      onPressed: () => _showHistory(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFilterBar(context, filters),
              ],
            ),
          ),
          if (listState.isIndexing)
            LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(primaryColor)),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // "Load Future" button - hide during search
                if (!isSearching)
                  SliverToBoxAdapter(
                    child: CupertinoButton(
                      onPressed: () => ref
                          .read(eventsListControllerProvider.notifier)
                          .loadFutureWeeks(),
                      child: Text('Load 3 More Weeks (Future)',
                          style: TextStyle(color: primaryColor)),
                    ),
                  ),

                // Week sections using SliverList for lazy rendering
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= populatedWeekIndices.length) return null;

                      final weekIndex = populatedWeekIndices[index];
                      // Safety check for array bounds, although weekIndex is derived from cache
                      if (weekIndex < 0 || weekIndex >= weeks.length) return const SizedBox.shrink();

                      final weekStart = weeks[weekIndex];
                      final weekEvents = displayCache[weekIndex]!;

                      return _buildWeekSectionWidget(
                          context, weekStart, weekEvents, weekIndex);
                    },
                    childCount: populatedWeekIndices.length,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildWeekSectionWidget(BuildContext context, DateTime weekStart,
      List<Event> weekEvents, int index) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekKey = weekStart.toIso8601String();
    final isExpanded = _expandedWeeks.contains(weekKey);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final now = DateTime.now();
    final isCurrentWeek = !now.isBefore(weekStart) &&
        !now.isAfter(weekEnd.add(const Duration(days: 1)));

    return Padding(
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
                    ? Border.all(color: primaryColor.withOpacity(0.4), width: 1)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            : CupertinoColors.secondaryLabel
                                                .resolveFrom(context),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    if (isCurrentWeek) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              primaryColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('NOW',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
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
          // Expanded Events
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground
                    .resolveFrom(context),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  const Divider(
                      height: 1,
                      color: CupertinoColors.separator,
                      indent: 20,
                      endIndent: 20),
                  // Render events eagerly *within* the visible week (weeks are lazy, content of open week is eager)
                  // This is acceptable as week-lists are usually small (<20 items)
                  // If very large, nested ListView.builder could be used but complicates scrolling.
                  // Column is fine here as it's inside a sliver.
                  ...weekEvents.map((event) => _buildEventTile(context, event)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, Event event) {
    final dateStr =
        '${event.startDate.month}/${event.startDate.day}/${event.startDate.year}';

    return GestureDetector(
      onTap: () {
        ref.read(historyServiceProvider).addEventToHistory(event);
        if (event.divisions != null && event.divisions!.length > 1) {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (_) => EventDivisionsScreen(event: event)));
        } else {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (_) => EventDetailScreen(event: event)));
        }
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
            Builder(builder: (context) {
              var flag = CountryUtils.getFlagEmoji(event.country);
              if (flag == '🌐' && event.location != null) {
                final parts = event.location!.split(', ');
                if (parts.isNotEmpty) {
                  flag = CountryUtils.getFlagEmoji(parts.last);
                }
              }
              return Text(flag, style: const TextStyle(fontSize: 16));
            }),
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

  Widget _buildFilterBar(BuildContext context, EventFilters filters) {
    final countries = ref.watch(eventsListControllerProvider).availableCountries;

    String getLabel(String base, List<String> selected) {
      if (selected.isEmpty) return base;
      String label = selected.first;
      if (selected.length > 1) {
        label += ' +${selected.length - 1}';
      }
      return label;
    }

    final controller = ref.read(eventsListControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: getLabel('Countries', filters.countries),
            isSelected: filters.countries.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Country',
              options: countries,
              currentValues: filters.countries,
              onSelected: (vals) {
                controller.setFilters(filters.copyWith(
                  countries: vals ?? [],
                  regions: [], // Reset regions
                ));
              },
            ),
          ),
          _buildFilterChip(
            label: getLabel('Regions', filters.regions),
            isSelected: filters.regions.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Region',
              options:
                  _allEventRegions, // Use the constant as base, or `regions`
              // Using `regions` (dynamically filtered) is better UX but `_allEventRegions` (static)
              // was used in original code for the picker options?
              // Original code used `_allEventRegions` for the options passed to picker.
              // Let's stick to `_allEventRegions` to preserve behavior,
              // OR use the dynamic `regions` if we are sure.
              // The original thought was:
              // `options: _allEventRegions` in original code.
              // But `final regions` variable was computed in build.
              // Let's use `_allEventRegions` as options to match org behavior.
              currentValues: filters.regions,
              onSelected: (vals) {
                controller.setFilters(filters.copyWith(regions: vals ?? []));
              },
            ),
          ),
          _buildFilterChip(
            label: getLabel('Grades', filters.grades),
            isSelected: filters.grades.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Grade',
              options: ['Middle School', 'Elementary School'],
              currentValues: filters.grades,
              showSearch: false,
              showAlphaIndex: false,
              onSelected: (vals) {
                controller.setFilters(filters.copyWith(grades: vals ?? []));
              },
            ),
          ),
          _buildFilterChip(
            label: getLabel('Type', filters.types),
            isSelected: filters.types.isNotEmpty,
            onTap: () => _showAlphabeticalPicker(
              title: 'Type',
              options: ['World', 'National', 'State', 'Signature', 'Other'],
              currentValues: filters.types,
              showSearch: false,
              showAlphaIndex: false,
              onSelected: (vals) {
                controller.setFilters(filters.copyWith(types: vals ?? []));
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select ${widget.title}',
                      style: const TextStyle(
                          fontSize: 20,
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
                        const SizedBox(width: 16),
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
              if (widget.showSearch) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child:
                      CupertinoSearchTextField(controller: _searchController),
                ),
              ] else ...[
                const SizedBox(height: 12),
              ],
              // List + Alpha Index
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: sortedAlpha.length,
                        itemBuilder: (context, index) {
                          final char = sortedAlpha[index];
                          final items = grouped[char]!;
                          _alphaKeys[char] = GlobalKey();

                          return Column(
                            key: _alphaKeys[char],
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
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
                                              fontSize: 16,
                                              decoration: TextDecoration.none),
                                        )),
                                        if (isSelected)
                                          Icon(
                                            CupertinoIcons
                                                .check_mark_circled_solid,
                                            color: primaryColor,
                                            size: 22,
                                          )
                                        else
                                          const Icon(
                                            CupertinoIcons.circle,
                                            color: CupertinoColors.systemGrey4,
                                            size: 22,
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
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                                .split('')
                                .map((char) {
                              final hasItems = grouped.containsKey(char);
                              return GestureDetector(
                                onTap: hasItems
                                    ? () => _scrollToAlpha(char)
                                    : null,
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
                      ),
                  ],
                ),
              ),
              // Cancel button only if needed?
              // The user said "dont include the giant bottom space".
              // `SafeArea` -> `CupertinoButton` ("Cancel") was at the bottom.
              // Maybe we generally don't need a "Cancel" button if we have "Done" at the top?
              // Standard iOS bottom sheets often have a "Done" at top right or a Cancel/Close button.
              // The screenshot shows "Clear" and "Done" at the top.
              // The previous code had a "Cancel" button at the bottom.
              // I'll keep it but ensure it doesn't add huge weird space.
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
