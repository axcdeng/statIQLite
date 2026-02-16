import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart';
import 'package:roboscout_iq/src/ui/screens/event_divisions_screen.dart';

/// Data holder for a team's live event stats.
class _TeamEventStats {
  final Event event;
  final int? rank;
  final double? avgPoints;
  final MatchModel? upcomingMatch;
  final int? skillsRank;
  final int? driverScore;
  final int? driverAttempts;
  final int? progScore;
  final int? progAttempts;

  _TeamEventStats({
    required this.event,
    this.rank,
    this.avgPoints,
    this.upcomingMatch,
    this.skillsRank,
    this.driverScore,
    this.driverAttempts,
    this.progScore,
    this.progAttempts,
  });
}

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  Color get _primaryColor => Theme.of(context).colorScheme.primary;

  /// Expansion state per team number — starts expanded for teams with events.
  final Map<String, bool> _expanded = {};

  /// Loaded stats per team number.
  final Map<String, _TeamEventStats> _teamStats = {};

  /// Whether we're currently loading stats.
  final Map<String, bool> _loading = {};

  bool _initialFetchDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialFetchDone) {
      _initialFetchDone = true;
      _fetchAllTeamStats();
    }
  }

  Future<void> _fetchAllTeamStats() async {
    // Yield to let UI render initial frame
    await Future.microtask(() {});

    final favTeams = ref.read(favoritesServiceProvider).getFavoriteTeams();
    for (final teamNum in favTeams) {
      _fetchStatsForTeam(teamNum);
    }
  }

  Future<void> _fetchStatsForTeam(String teamNumber) async {
    if (_loading[teamNumber] == true) return;
    setState(() => _loading[teamNumber] = true);

    try {
      final teamsRepo = ref.read(teamsRepositoryProvider);
      final eventsRepo = ref.read(eventsRepositoryProvider);
      final matchesRepo = ref.read(matchesRepositoryProvider);

      // 1. Find team — try local cache first (instant), then fast RobotEvents API
      var team = teamsRepo.findLocalTeamByNumber(teamNumber);
      if (team == null) {
        team = await teamsRepo.getTeamByNumber(teamNumber);
        if (team == null) {
          if (mounted) setState(() => _loading[teamNumber] = false);
          return;
        }
      }

      // 2. Get team's current-season events
      final events = await teamsRepo.getTeamEvents(team.id,
          seasonId: ref.read(settingsProvider).primarySeasonId);

      // 3. Find an event that is active TODAY
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      Event? activeEvent;
      for (final e in events) {
        final start =
            DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
        final end = DateTime(e.endDate.year, e.endDate.month, e.endDate.day);
        if (!today.isBefore(start) && !today.isAfter(end)) {
          activeEvent = e;
          break;
        }
      }

      if (activeEvent == null) {
        if (mounted) setState(() => _loading[teamNumber] = false);
        return;
      }

      // 4. Fetch rankings, matches, skills in parallel
      final rankingsFuture = eventsRepo.getEventRankings(activeEvent.id);
      final matchesFuture = matchesRepo
          .fetchMatches(activeEvent.id)
          .then((_) => matchesRepo.getMatchesForEvent(activeEvent!.id));
      final skillsFuture = eventsRepo.getEventSkills(activeEvent.id);

      final results = await Future.wait([
        rankingsFuture,
        matchesFuture,
        skillsFuture,
      ]);

      final rankings = results[0] as List<Map<String, dynamic>>;
      final matches = results[1] as List<MatchModel>;
      final skills = results[2] as List<Map<String, dynamic>>;

      // Find team's ranking
      int? rank;
      double? avgPoints;
      for (final r in rankings) {
        final rTeam = r['team'] as Map<String, dynamic>?;
        if (rTeam != null) {
          final rName = rTeam['name'] as String?;
          if (rName == teamNumber) {
            rank = r['rank'] as int?;
            final ap = r['average_points'];
            if (ap is num) avgPoints = ap.toDouble();
            break;
          }
        }
      }

      // Find upcoming match (next unscored match this team is in)
      MatchModel? upcoming;
      final teamMatches = matches.where((m) =>
          m.redAllianceTeamNums.contains(teamNumber) ||
          m.blueAllianceTeamNums.contains(teamNumber) ||
          m.redAllianceTeamIds.contains(team!.id) ||
          m.blueAllianceTeamIds.contains(team!.id));

      for (final m in teamMatches) {
        if (m.redScore == null && m.blueScore == null) {
          upcoming = m;
          break;
        }
        if ((m.redScore ?? 0) == 0 &&
            (m.blueScore ?? 0) == 0 &&
            m.scheduledTime != null &&
            m.scheduledTime!.isAfter(now)) {
          upcoming = m;
          break;
        }
      }

      // Find team's skills
      int? skillsRank;
      int? driverScore;
      int? driverAttempts;
      int? progScore;
      int? progAttempts;

      // Build per-team aggregate from individual skill runs
      // Skills entries: each has team, type (0=driver, 1=programming), score, attempts, rank
      final teamSkillEntries = skills.where((s) {
        final sTeam = s['team'] as Map<String, dynamic>?;
        final sName = sTeam?['name'] as String?;
        return sName == teamNumber;
      }).toList();

      for (final s in teamSkillEntries) {
        final type = s['type'] as String?;
        final score = s['score'] as int?;
        final attempts = s['attempts'] as int?;
        final r = s['rank'] as int?;

        if (type == 'driver') {
          driverScore = score;
          driverAttempts = attempts;
          if (r != null) skillsRank ??= r;
        } else if (type == 'programming') {
          progScore = score;
          progAttempts = attempts;
        }
      }

      if (mounted) {
        setState(() {
          _teamStats[teamNumber] = _TeamEventStats(
            event: activeEvent!,
            rank: rank,
            avgPoints: avgPoints,
            upcomingMatch: upcoming,
            skillsRank: skillsRank,
            driverScore: driverScore,
            driverAttempts: driverAttempts,
            progScore: progScore,
            progAttempts: progAttempts,
          );
          _expanded[teamNumber] = _expanded[teamNumber] ?? true; // auto-expand
          _loading[teamNumber] = false;
        });
      }
    } catch (e) {
      print('Error fetching stats for $teamNumber: $e');
      if (mounted) setState(() => _loading[teamNumber] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesService = ref.watch(favoritesServiceProvider);
    final favTeams = favoritesService.getFavoriteTeams();
    final favEventsSkus = favoritesService.getFavoriteEvents();
    final eventsRepo = ref.read(eventsRepositoryProvider);
    final favEvents = eventsRepo.getLocalEvents(favEventsSkus);

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Favorites'),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // TEAMS SECTION
              if (favTeams.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 20, 16, 8),
                    child: Text('TEAMS',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                            letterSpacing: 0.5)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final teamNum = favTeams[index];
                      return _buildTeamCard(teamNum, key: ValueKey(teamNum));
                    },
                    childCount: favTeams.length,
                  ),
                ),
              ],

              // EVENTS SECTION
              if (favEvents.isNotEmpty)
                SliverToBoxAdapter(
                  child: CupertinoListSection.insetGrouped(
                    header: const Text('EVENTS'),
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: favEvents.map((event) {
                      return CupertinoListTile.notched(
                        key: ValueKey(event.sku),
                        leading:
                            Icon(CupertinoIcons.calendar, color: _primaryColor),
                        title: Text(event.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.label
                                    .resolveFrom(context))),
                        subtitle: Text(event.sku ?? '',
                            style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context))),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          if (event.divisions != null &&
                              event.divisions!.length > 1) {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (_) =>
                                    EventDivisionsScreen(event: event)));
                          } else {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (_) =>
                                    EventDetailScreen(event: event)));
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),

              // EMPTY STATE
              if (favTeams.isEmpty && favEvents.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Center(
                      child: Text(
                        'No favorites yet.\nStar teams or events to see them here!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 17),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(String teamNumber, {Key? key}) {
    final hasStats = _teamStats.containsKey(teamNumber);
    final isLoading = _loading[teamNumber] == true;
    final isExpanded = _expanded[teamNumber] ?? false;
    final stats = _teamStats[teamNumber];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Team header row
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Navigate to team lookup
              ref.read(teamSearchQueryProvider.notifier).state = teamNumber;
              ref.read(bottomNavIndexProvider.notifier).state = 2;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(CupertinoIcons.person_2_fill,
                      color: _primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(teamNumber,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: CupertinoColors.label.resolveFrom(context))),
                  ),
                  if (isLoading)
                    const CupertinoActivityIndicator(radius: 8)
                  else if (hasStats)
                    GestureDetector(
                      onTap: () {
                        setState(() => _expanded[teamNumber] = !isExpanded);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          isExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: _primaryColor,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Collapsible stats panel
          if (hasStats && isExpanded) _buildStatsPanel(stats!),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(_TeamEventStats stats) {
    final timeStr = stats.upcomingMatch?.scheduledTime != null
        ? DateFormat('h:mm a').format(stats.upcomingMatch!.scheduledTime!)
        : null;
    final matchLabel = stats.upcomingMatch?.shortName;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top:
              BorderSide(color: CupertinoColors.separator.resolveFrom(context)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Name with accent bar — tappable to view event
          GestureDetector(
            onTap: () {
              if (stats.event.divisions != null &&
                  stats.event.divisions!.length > 1) {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => EventDivisionsScreen(event: stats.event)));
              } else {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => EventDetailScreen(event: stats.event)));
              }
            },
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stats.event.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: CupertinoColors.label.resolveFrom(context),
                        letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right,
                    size: 14, color: CupertinoColors.systemGrey),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Next match pill (if available)
          if (matchLabel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryColor.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.flag_fill,
                      size: 14, color: _primaryColor),
                  const SizedBox(width: 8),
                  Text('Next: ',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              CupertinoColors.systemGrey.resolveFrom(context),
                          fontWeight: FontWeight.w500)),
                  Text(matchLabel,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor)),
                  const Spacer(),
                  if (timeStr != null)
                    Text(timeStr,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context))),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // 2x2 stat grid
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  label: 'Rank',
                  value: stats.rank?.toString() ?? '—',
                  icon: CupertinoIcons.chart_bar_fill,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  label: 'Avg Pts',
                  value: stats.avgPoints != null
                      ? stats.avgPoints!.toStringAsFixed(1)
                      : '—',
                  icon: CupertinoIcons.star_fill,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  label: 'Driver',
                  value: stats.driverScore?.toString() ?? '—',
                  subtitle: stats.driverAttempts != null
                      ? '${stats.driverAttempts} att'
                      : null,
                  icon: CupertinoIcons.game_controller_solid,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  label: 'Auto',
                  value: stats.progScore?.toString() ?? '—',
                  subtitle: stats.progAttempts != null
                      ? '${stats.progAttempts} att'
                      : null,
                  icon: CupertinoIcons.chevron_left_slash_chevron_right,
                ),
              ),
            ],
          ),

          // Skills rank footer
          if (stats.skillsRank != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Skills Rank: #${stats.skillsRank}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor.withOpacity(0.7)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: _primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.label.resolveFrom(context),
                            letterSpacing: -0.5)),
                    if (subtitle != null) ...[
                      const SizedBox(width: 6),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context))),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
