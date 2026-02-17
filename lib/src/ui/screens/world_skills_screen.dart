import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';

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

  // Cache for TrueSkill data
  List<Team> _msTrueSkill = [];
  List<Team> _esTrueSkill = [];

  bool _isLoading = true;
  String _errorMessage = '';

  String _gradeLevel = 'Middle School'; // Default selection
  String _metric = 'Skills'; // 'Skills', 'TrueSkill', 'EPA'

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final client = ref.read(apiClientProvider);

      if (_metric == 'Skills') {
        // Fetch both MS and ES in parallel
        final results = await Future.wait([
          client.getGlobalSkills(gradeLevel: 'Middle School'),
          client.getGlobalSkills(gradeLevel: 'Elementary School'),
        ]);

        // Sort in background isolate to prevent UI freeze
        // This must happen outside setState
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
        final results = await Future.wait([
          client.getGlobalTrueSkillRankings(gradeLevel: 'Middle School'),
          client.getGlobalTrueSkillRankings(gradeLevel: 'Elementary School'),
        ]);

        if (mounted) {
          setState(() {
            _msTrueSkill = results[0];
            _esTrueSkill = results[1];
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
            onPressed: _fetchData,
            child: Icon(CupertinoIcons.refresh, color: primaryColor),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0)
                    .copyWith(bottom: 12.0),
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
                          // If we switch metrics, we might need to fetch data if not already cached
                          // But for simplicity and to ensure freshness, let's fetch.
                          // Actually, user experience is better if we cache.
                          // But sticking to "same logic as world skills" which fetches on load.
                          // Let's fetch data when metric changes.
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

    if (_metric == 'Skills') {
      final currentList =
          _gradeLevel == 'Middle School' ? _msSkills : _esSkills;
      if (currentList.isEmpty) {
        return const Center(child: Text('No data found'));
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemExtent: 72.0,
        itemCount: currentList.length,
        itemBuilder: (context, index) =>
            _buildSkillTile(currentList[index], context),
      );
    } else if (_metric == 'TrueSkill') {
      final currentList =
          _gradeLevel == 'Middle School' ? _msTrueSkill : _esTrueSkill;
      if (currentList.isEmpty) {
        return const Center(child: Text('No data found'));
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemExtent: 72.0,
        itemCount: currentList.length,
        itemBuilder: (context, index) =>
            _buildTrueSkillTile(currentList[index], index + 1, context),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSkillTile(Map<String, dynamic> item, BuildContext context) {
    final rank = item['rank'];
    final team = item['team'] as Map<String, dynamic>;
    final number = team['number'];
    final name = team['name'] ?? '';
    final score = item['score'];
    final prog = item['programming'];
    final driver = item['driver'];
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
            // Rank Circle
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground
                    .resolveFrom(context),
                shape: BoxShape.circle,
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
                color: primaryColor.withOpacity(0.15),
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
    // According to memory, 'teamwork' maps to trueskill rating (Mu)
    final score = team.statiq?['teamwork'] ?? 0.0;
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
            // Rank Circle
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground
                    .resolveFrom(context),
                shape: BoxShape.circle,
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
                color: primaryColor.withOpacity(0.15),
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
