import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';

// ---------------------------------------------------------------------------
// Isolate sort helper
// ---------------------------------------------------------------------------
List<Map<String, dynamic>> _sortSkillsList(List<dynamic> input) {
  final list = List<Map<String, dynamic>>.from(input);
  int sortRank(Map<String, dynamic> a, Map<String, dynamic> b) {
    final r1 = a['rank'] is num
        ? (a['rank'] as num).toInt()
        : int.tryParse(a['rank'].toString()) ?? 999;
    final r2 = b['rank'] is num
        ? (b['rank'] as num).toInt()
        : int.tryParse(b['rank'].toString()) ?? 999;
    return r1.compareTo(r2);
  }

  list.sort(sortRank);
  return list;
}

// ---------------------------------------------------------------------------
// Tab-visit debounce
// ---------------------------------------------------------------------------
const Duration _kRefreshDebounce = Duration(seconds: 30);

class WorldSkillsScreen extends ConsumerStatefulWidget {
  const WorldSkillsScreen({super.key});

  @override
  ConsumerState<WorldSkillsScreen> createState() => _WorldSkillsScreenState();
}

class _WorldSkillsScreenState extends ConsumerState<WorldSkillsScreen> {
  // ── Data ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _msSkills = [];
  List<Map<String, dynamic>> _esSkills = [];
  List<Team> _trueSkills = [];

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showNoDataBanner = false;

  // ── Filters ───────────────────────────────────────────────────────────────
  String _gradeLevel = 'Middle School';
  String _metric = 'Skills'; // 'Skills' | 'TrueSkill' | 'EPA'
  String? _selectedCountry;

  late TextEditingController _countryController;

  // ── Debounce ──────────────────────────────────────────────────────────────
  /// Last successful background refresh timestamp per metric.
  final Map<String, DateTime> _lastRefreshed = {};

  // ── Tab-visit detection ───────────────────────────────────────────────────
  /// Index of this tab in the bottom nav (Leaderboards).
  static const int _tabIndex = 4;
  int? _prevNavIndex;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController();
    _fetchData(); // Initial load (shows spinner)
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detect tab-visit by watching the nav index provider.
    final navIndex = ref.read(bottomNavIndexProvider);
    final justActivated = navIndex == _tabIndex && _prevNavIndex != _tabIndex;
    _prevNavIndex = navIndex;

    if (justActivated) {
      _backgroundRefresh();
    }
  }

  // ---------------------------------------------------------------------------
  // Data fetching
  // ---------------------------------------------------------------------------

  /// Silently refreshes in the background (no loading spinner).
  /// Respects the 30-second debounce per metric.
  /// Skips if the initial load is still in progress to avoid concurrent
  /// fetches hitting the in-flight gate and returning empty data.
  void _backgroundRefresh() {
    if (_isLoading) return; // initial fetch still in flight — skip
    final now = DateTime.now();
    final last = _lastRefreshed[_metric];
    if (last != null && now.difference(last) < _kRefreshDebounce) return;
    _fetchData(forceRefresh: true, isPullToRefresh: true);
  }

  Future<void> _fetchData(
      {bool forceRefresh = false,
      bool isPullToRefresh = false,
      bool isManual = false}) async {
    if (!isPullToRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final repo = ref.read(leaderboardRepositoryProvider);

      if (_metric == 'Skills') {
        final results = await Future.wait([
          repo.getGlobalSkills('Middle School', forceRefresh: forceRefresh),
          repo.getGlobalSkills('Elementary School', forceRefresh: forceRefresh),
        ]);

        final sortedResults = await Future.wait([
          compute(_sortSkillsList, results[0]),
          compute(_sortSkillsList, results[1]),
        ]);

        if (mounted) {
          final gotData =
              sortedResults[0].isNotEmpty || sortedResults[1].isNotEmpty;
          setState(() {
            _msSkills = sortedResults[0];
            _esSkills = sortedResults[1];
            _isLoading = false;
            if (gotData) {
              _showNoDataBanner = false;
            } else if (isManual || isPullToRefresh) {
              _showNoDataBanner = true;
            }
          });
        }
      } else if (_metric == 'TrueSkill') {
        final results = await repo.getGlobalTrueSkillRankings(
          country: _selectedCountry,
          forceRefresh: forceRefresh,
        );

        if (mounted) {
          setState(() {
            _trueSkills = results;
            _isLoading = false;
            if (results.isNotEmpty) {
              _showNoDataBanner = false;
            } else if (isManual || isPullToRefresh) {
              _showNoDataBanner = true;
            }
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }

      // Record successful fetch time for debounce.
      _lastRefreshed[_metric] = DateTime.now();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          if (isManual || isPullToRefresh) _showNoDataBanner = true;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Watch nav index so didChangeDependencies fires on tab switches.
    ref.watch(bottomNavIndexProvider);

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        navigationBar: CupertinoNavigationBar(
          middle: const Text('World Leaderboards'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _fetchData(forceRefresh: true, isManual: true),
            child: Icon(CupertinoIcons.refresh, color: primaryColor),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Metric Selector ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<String>(
                    thumbColor: primaryColor,
                    backgroundColor: CupertinoColors.tertiarySystemFill,
                    groupValue: _metric,
                    onValueChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _metric = value;
                          _showNoDataBanner = false;
                          _fetchData();
                        });
                      }
                    },
                    children: {
                      'Skills': _segLabel(
                          'Skills', _metric == 'Skills', context, primaryColor),
                      'TrueSkill': _segLabel('TrueSkill',
                          _metric == 'TrueSkill', context, primaryColor),
                      'EPA': _segLabel(
                          'EPA', _metric == 'EPA', context, primaryColor),
                    },
                  ),
                ),
              ),

              // ── Grade Selector (Skills only) ─────────────────────────────
              if (_metric == 'Skills')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0)
                      .copyWith(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<String>(
                      thumbColor: primaryColor,
                      backgroundColor: CupertinoColors.tertiarySystemFill,
                      groupValue: _gradeLevel,
                      onValueChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _gradeLevel = value;
                            _fetchData();
                          });
                        }
                      },
                      children: {
                        'Middle School': _segLabel(
                            'Middle School',
                            _gradeLevel == 'Middle School',
                            context,
                            primaryColor),
                        'Elementary School': _segLabel(
                            'Elementary School',
                            _gradeLevel == 'Elementary School',
                            context,
                            primaryColor),
                      },
                    ),
                  ),
                ),

              // ── Country Filter (TrueSkill only) ──────────────────────────
              /*
              // NOTE FOR FUTURE AI: The country filter is intentionally disabled for now per user request.
              // To re-enable, uncomment this block and ensure _selectedCountry logic in _fetchData is sync'd.
              if (_metric == 'TrueSkill')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0)
                      .copyWith(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoSearchTextField(
                        controller: _countryController,
                        placeholder: 'Country',
                        onChanged: (value) {
                          setState(() {
                            if (value.trim().isEmpty) {
                              _suggestions = [];
                              if (_selectedCountry != null) {
                                _selectedCountry = null;
                                _fetchData();
                              }
                            } else {
                              _suggestions = AppConstants.vexIqCountries
                                  .where((c) => c
                                      .toLowerCase()
                                      .startsWith(value.toLowerCase()))
                                  .toList();
                              if (_suggestions.length == 1 &&
                                  _suggestions.first.toLowerCase() ==
                                      value.trim().toLowerCase()) {
                                _suggestions = [];
                              }
                            }
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            _selectedCountry =
                                value.trim().isEmpty ? null : value.trim();
                            _suggestions = [];
                            _fetchData();
                          });
                        },
                      ),
                      if (_suggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: CupertinoColors
                                .secondarySystemGroupedBackground
                                .resolveFrom(context),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(suggestion,
                                    style: TextStyle(
                                        color: CupertinoColors.label
                                            .resolveFrom(context))),
                                onPressed: () {
                                  setState(() {
                                    _countryController.text = suggestion;
                                    _selectedCountry = suggestion;
                                    _suggestions = [];
                                    _fetchData();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              */

              // ── List + no-data banner ─────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    _buildContent(context),
                    if (_showNoDataBanner) _buildNoDataBanner(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Segment label helper
  // ---------------------------------------------------------------------------
  Widget _segLabel(String label, bool active, BuildContext ctx, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: active
                  ? Theme.of(ctx).colorScheme.onPrimary
                  : CupertinoColors.secondaryLabel.resolveFrom(ctx))),
    );
  }

  // ---------------------------------------------------------------------------
  // No-data banner
  // ---------------------------------------------------------------------------
  Widget _buildNoDataBanner(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle,
                color: Colors.white70, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No data found',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.xmark,
                  color: Colors.white70, size: 16),
              onPressed: () => setState(() => _showNoDataBanner = false),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_metric == 'EPA') {
      return const Center(child: Text('Coming soon'));
    }

    final List<Widget> slivers = [
      CupertinoSliverRefreshControl(
        onRefresh: () => _fetchData(forceRefresh: true, isPullToRefresh: true),
      ),
    ];

    if (_metric == 'Skills') {
      final currentList =
          _gradeLevel == 'Middle School' ? _msSkills : _esSkills;
      if (currentList.isEmpty) {
        slivers.add(const SliverFillRemaining(
          child: Center(child: Text('No data')),
        ));
      } else {
        slivers.add(SliverFixedExtentList(
          itemExtent: 72.0,
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSkillTile(currentList[index], context),
            childCount: currentList.length,
          ),
        ));
      }
    } else if (_metric == 'TrueSkill') {
      final currentList = _trueSkills;
      if (currentList.isEmpty) {
        slivers.add(const SliverFillRemaining(
          child: Center(child: Text('No data')),
        ));
      } else {
        slivers.add(SliverFixedExtentList(
          itemExtent: 72.0,
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildTrueSkillTile(currentList[index], index + 1, context),
            childCount: currentList.length,
          ),
        ));
      }
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );
  }

  // ---------------------------------------------------------------------------
  // Field-shape migration helper
  // ---------------------------------------------------------------------------

  /// Resolves a field value from [item] by trying [newKey] first, then each
  /// [legacyPaths] nested key list in order. Returns the first non-null value.
  dynamic _resolveField(Map<String, dynamic> item, String newKey,
      List<List<String>> legacyPaths) {
    if (item.containsKey(newKey) && item[newKey] != null) return item[newKey];
    for (final path in legacyPaths) {
      dynamic cur = item;
      for (final key in path) {
        if (cur is Map && cur.containsKey(key)) {
          cur = cur[key];
        } else {
          cur = null;
          break;
        }
      }
      if (cur != null) return cur;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Skill tile (World Skills)
  // ---------------------------------------------------------------------------

  Widget _buildSkillTile(Map<String, dynamic> item, BuildContext context) {
    final rank = item['rank'];

    // New flat API fields with backward-compat fallbacks for cached old shape.
    final number = _resolveField(item, 'team_number', [
          ['team', 'number']
        ])?.toString() ??
        '';
    final name = _resolveField(item, 'team_name', [
          ['team', 'name']
        ])?.toString() ??
        '';
    final score = (_resolveField(item, 'score', [
          ['skills', 'combined']
        ]) ??
        0);
    final prog = (_resolveField(item, 'programming_score', [
          ['skills', 'programming'],
          ['programming']
        ]) ??
        0);
    final driver = (_resolveField(item, 'driver_score', [
          ['skills', 'driver'],
          ['driver']
        ]) ??
        0);

    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        ref.read(teamSearchQueryProvider.notifier).state = number;
        ref.read(bottomNavIndexProvider.notifier).state = 2;
      },
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _rankBadge('$rank', context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(number,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color:
                                  CupertinoColors.label.resolveFrom(context))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.label
                                    .resolveFrom(context))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Prog: $prog • Driver: $driver',
                      style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _scorePill('$score', primaryColor),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_right,
                size: 14, color: CupertinoColors.systemGrey3),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TrueSkill tile
  // ---------------------------------------------------------------------------

  Widget _buildTrueSkillTile(Team team, int rank, BuildContext context) {
    final number = team.number;
    final name = team.name;
    final score = team.trueskill ?? 0.0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        ref.read(teamSearchQueryProvider.notifier).state = number;
        ref.read(bottomNavIndexProvider.notifier).state = 2;
      },
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _rankBadge(
              _selectedCountry != null
                  ? '${team.worldRank ?? "?"} / $rank'
                  : '$rank',
              context,
              small: _selectedCountry != null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(number,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color:
                                  CupertinoColors.label.resolveFrom(context))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.label
                                    .resolveFrom(context))),
                      ),
                    ],
                  ),
                  if ((team.organization?.isNotEmpty == true) ||
                      (team.location?.isNotEmpty == true)) ...[
                    const SizedBox(height: 1),
                    Text(
                        (team.organization?.isNotEmpty == true)
                            ? team.organization!
                            : team.location!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _scorePill((score as num).toStringAsFixed(2), primaryColor,
                fontSize: 16),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_right,
                size: 14, color: CupertinoColors.systemGrey3),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared tile sub-widgets
  // ---------------------------------------------------------------------------

  Widget _rankBadge(String label, BuildContext context, {bool small = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: small ? 11 : 14,
              color: CupertinoColors.label.resolveFrom(context))),
    );
  }

  Widget _scorePill(String label, Color primary, {double fontSize = 18}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w800, color: primary, fontSize: fontSize)),
    );
  }
}
