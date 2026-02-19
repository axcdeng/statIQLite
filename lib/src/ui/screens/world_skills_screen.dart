import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/constants.dart';

// Standalone sort function for isolate
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

class WorldSkillsScreen extends ConsumerStatefulWidget {
  const WorldSkillsScreen({super.key});

  @override
  ConsumerState<WorldSkillsScreen> createState() => _WorldSkillsScreenState();
}

class _WorldSkillsScreenState extends ConsumerState<WorldSkillsScreen> {
  // Cache for skills data
  List<Map<String, dynamic>> _msSkills = [];
  List<Map<String, dynamic>> _esSkills = [];

  // Cache for TrueSkill data (Unified)
  List<Team> _trueSkills = [];

  bool _isLoading = true;
  String _errorMessage = '';

  String _gradeLevel = 'Middle School'; // Default selection
  String _metric = 'Skills'; // 'Skills', 'TrueSkill', 'EPA'
  String? _selectedCountry;

  late TextEditingController _countryController;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(
      {bool forceRefresh = false, bool isPullToRefresh = false}) async {
    if (!isPullToRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final repo = ref.read(leaderboardRepositoryProvider);

      if (_metric == 'Skills') {
        // Fetch both MS and ES in parallel
        final results = await Future.wait([
          repo.getGlobalSkills('Middle School', forceRefresh: forceRefresh),
          repo.getGlobalSkills('Elementary School', forceRefresh: forceRefresh),
        ]);

        // Sort in background isolate to prevent UI freeze
        final sortedResults = await Future.wait([
          compute(_sortSkillsList, results[0]),
          compute(_sortSkillsList, results[1]),
        ]);

        if (mounted) {
          setState(() {
            _msSkills = sortedResults[0];
            _esSkills = sortedResults[1];
            _isLoading = false;
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
          });
        }
      } else {
        // EPA or other future metrics
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _fetchData(forceRefresh: true),
            child: Icon(CupertinoIcons.refresh, color: primaryColor),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Metric Selector (Top)
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
                          _fetchData();
                        });
                      }
                    },
                    children: {
                      'Skills': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('Skills',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _metric == 'Skills'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : CupertinoColors.secondaryLabel
                                        .resolveFrom(context))),
                      ),
                      'TrueSkill': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('TrueSkill',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _metric == 'TrueSkill'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : CupertinoColors.secondaryLabel
                                        .resolveFrom(context))),
                      ),
                      'EPA': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('EPA',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _metric == 'EPA'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : CupertinoColors.secondaryLabel
                                        .resolveFrom(context))),
                      ),
                    },
                  ),
                ),
              ),

              // Grade Level Selector (Conditionally below metric selector)
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
                        'Middle School': Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text('Middle School',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _gradeLevel == 'Middle School'
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context))),
                        ),
                        'Elementary School': Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text('Elementary School',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _gradeLevel == 'Elementary School'
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context))),
                        ),
                      },
                    ),
                  ),
                ),

              // Country Filter for TrueSkill (with Autofill Suggestions)
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
                              // Don't show suggestion if exact match
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

              Expanded(
                child: _buildContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

    List<Widget> slivers = [];

    // Add Pull-to-Refresh
    slivers.add(CupertinoSliverRefreshControl(
      onRefresh: () => _fetchData(forceRefresh: true, isPullToRefresh: true),
    ));

    if (_metric == 'Skills') {
      final currentList =
          _gradeLevel == 'Middle School' ? _msSkills : _esSkills;
      if (currentList.isEmpty) {
        slivers.add(const SliverFillRemaining(
          child: Center(child: Text('No data found')),
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
          child: Center(child: Text('No data found')),
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

  Widget _buildSkillTile(Map<String, dynamic> item, BuildContext context) {
    final rank = item['rank'];
    final teamRaw = item['team'];
    final team = teamRaw is Map ? Map<String, dynamic>.from(teamRaw) : {};
    final number = team['number'] ?? '';
    final name = team['name'] ?? '';
    final skills = item['skills'] != null
        ? Map<String, dynamic>.from(item['skills'])
        : null;
    final score = skills?['combined'] ?? item['score'] ?? 0;
    final prog = skills?['programming'] ?? item['programming'] ?? 0;
    final driver = skills?['driver'] ?? item['driver'] ?? 0;
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
            // Rank Container
            Container(
              constraints: const BoxConstraints(minWidth: 36),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground
                    .resolveFrom(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('$rank',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: CupertinoColors.label.resolveFrom(context))),
            ),
            const SizedBox(width: 12),
            // Team Info
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
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2), // Minimal gap
                  Text('Prog: $prog • Driver: $driver',
                      style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_right,
                size: 14, color: CupertinoColors.systemGrey3),
          ],
        ),
      ),
    );
  }

  Widget _buildTrueSkillTile(Team team, int rank, BuildContext context) {
    final number = team.number;
    final name = team.name;
    // Use trueskill from model which robustly handles new API structure
    final score = team.trueskill ?? 0.0;
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
            // Rank Container
            Container(
              constraints: const BoxConstraints(minWidth: 36),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground
                    .resolveFrom(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: _selectedCountry != null
                  ? RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${team.worldRank ?? "?"}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: CupertinoColors.systemGrey
                                    .resolveFrom(context)),
                          ),
                          TextSpan(
                            text: ' / ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color:
                                    CupertinoColors.label.resolveFrom(context)),
                          ),
                          TextSpan(
                            text: '$rank',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color:
                                    CupertinoColors.label.resolveFrom(context)),
                          ),
                        ],
                      ),
                    )
                  : Text('$rank',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: CupertinoColors.label.resolveFrom(context))),
            ),
            const SizedBox(width: 12),
            // Team Info
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
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2), // Minimal gap
                  // TrueSkill doesn't have Prog/Driver breakdown usually displayed here
                  // Maybe display organization or location?
                  Text(team.organization ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (score as num).toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  fontSize: 16, // Slightly smaller for decimals
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_right,
                size: 14, color: CupertinoColors.systemGrey3),
          ],
        ),
      ),
    );
  }
}
