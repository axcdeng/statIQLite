import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/team_at_event_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;
  final Team? initiallySelectedTeam;
  const EventDetailScreen(
      {super.key, required this.event, this.initiallySelectedTeam});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Fetch data for this event on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamsRepositoryProvider).fetchTeams(widget.event.id);
      ref.read(matchesRepositoryProvider).fetchMatches(widget.event.id);

      // Auto-navigate if team provided
      if (widget.initiallySelectedTeam != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TeamAtEventScreen(
                team: widget.initiallySelectedTeam!, event: widget.event)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF49CAEB);
    final isFavorite = widget.event.sku != null &&
        ref.watch(favoritesServiceProvider).isEventFavorite(widget.event.sku!);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text(widget.event.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
        backgroundColor: CupertinoColors.black.withOpacity(0.9),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.event.sku != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
                  color:
                      isFavorite ? CupertinoColors.systemYellow : primaryColor,
                  size: 20,
                ),
                onPressed: () async {
                  final service = ref.read(favoritesServiceProvider);
                  final sku = widget.event.sku!;
                  if (service.isEventFavorite(sku)) {
                    await service.removeFavoriteEvent(sku);
                  } else {
                    await service.addFavoriteEvent(sku);
                  }
                },
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search,
                  color: primaryColor, size: 20),
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).state = 2;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    thumbColor: primaryColor,
                    backgroundColor: CupertinoColors.tertiarySystemFill,
                    groupValue: _tabController.index,
                    children: {
                      0: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Teams',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 0
                                      ? CupertinoColors.white
                                      : CupertinoColors.label))),
                      1: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Matches',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 1
                                      ? CupertinoColors.white
                                      : CupertinoColors.label))),
                      2: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Rankings',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 2
                                      ? CupertinoColors.white
                                      : CupertinoColors.label))),
                      3: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Skills',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 3
                                      ? CupertinoColors.white
                                      : CupertinoColors.label))),
                      4: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Awards',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 4
                                      ? CupertinoColors.white
                                      : CupertinoColors.label))),
                    },
                    onValueChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          _tabController.index = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _tabController.index,
                  children: [
                    _TeamsList(event: widget.event),
                    _MatchesList(event: widget.event),
                    _RankingsList(event: widget.event),
                    _SkillsList(event: widget.event),
                    _AwardsList(event: widget.event),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- TEAMS ----------

class _TeamsList extends ConsumerWidget {
  final Event event;
  const _TeamsList({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsRepo = ref.watch(teamsRepositoryProvider);
    const primaryColor = Color(0xFF49CAEB);

    return ValueListenableBuilder<Box<Team>>(
      valueListenable: teamsRepo.watchTeams(),
      builder: (context, box, _) {
        final teams = teamsRepo.getTeamsForEvent(event.id);
        if (teams.isEmpty) {
          return const Center(child: CupertinoActivityIndicator());
        }

        // Sort teams by numeric prefix, then letter suffix
        teams.sort((a, b) {
          final aNum =
              int.tryParse(a.number.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bNum =
              int.tryParse(b.number.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          if (aNum != bNum) return aNum.compareTo(bNum);
          final aSuffix = a.number.replaceAll(RegExp(r'[0-9]'), '');
          final bSuffix = b.number.replaceAll(RegExp(r'[0-9]'), '');
          return aSuffix.compareTo(bSuffix);
        });

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('TEAMS'),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: teams.map((team) {
                return CupertinoListTile.notched(
                  leading: const Icon(CupertinoIcons.person_2_fill,
                      color: primaryColor),
                  title: Text(team.number,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(team.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) =>
                            TeamAtEventScreen(team: team, event: event)));
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ---------- MATCHES ----------

class _MatchesList extends ConsumerStatefulWidget {
  final Event event;
  const _MatchesList({required this.event});

  @override
  ConsumerState<_MatchesList> createState() => _MatchesListState();
}

class _MatchesListState extends ConsumerState<_MatchesList> {
  bool _qualsExpanded = true;
  bool _finalsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final matchesRepo = ref.watch(matchesRepositoryProvider);
    return ValueListenableBuilder<Box<MatchModel>>(
      valueListenable: matchesRepo.watchMatches(),
      builder: (context, box, _) {
        final matches = matchesRepo.getMatchesForEvent(widget.event.id);
        if (matches.isEmpty) {
          return const Center(
              child: Text('No matches loaded.',
                  style: TextStyle(color: CupertinoColors.secondaryLabel)));
        }

        matches.sort((a, b) {
          if (a.round != b.round) return a.round.compareTo(b.round);
          if (a.instance != b.instance) return a.instance.compareTo(b.instance);
          return a.matchNum.compareTo(b.matchNum);
        });

        final quals = matches.where((m) => m.isQualifier).toList();
        final finals = matches.where((m) => m.isFinals).toList();

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            if (quals.isNotEmpty) ...[
              _buildCollapsibleHeader(
                'QUALIFICATION MATCHES (${quals.length})',
                _qualsExpanded,
                () => setState(() => _qualsExpanded = !_qualsExpanded),
              ),
              if (_qualsExpanded)
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: quals.map((m) => MatchTile(match: m)).toList(),
                ),
            ],
            if (finals.isNotEmpty) ...[
              _buildCollapsibleHeader(
                'FINALS (${finals.length})',
                _finalsExpanded,
                () => setState(() => _finalsExpanded = !_finalsExpanded),
              ),
              if (_finalsExpanded)
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: finals.map((m) => MatchTile(match: m)).toList(),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCollapsibleHeader(
      String title, bool isExpanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? CupertinoIcons.chevron_up
                  : CupertinoIcons.chevron_down,
              size: 14,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- MATCH TILE ----------

class MatchTile extends StatelessWidget {
  final MatchModel match;
  const MatchTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final rScore = match.redScore ?? 0;
    final bScore = match.blueScore ?? 0;
    final finalScore = (rScore > bScore) ? rScore : bScore;
    final isSplitScore = rScore != bScore;

    final redTeams = match.redAllianceTeamNums.isNotEmpty
        ? match.redAllianceTeamNums
        : match.redAllianceTeamIds.map((id) => id.toString()).toList();

    final blueTeams = match.blueAllianceTeamNums.isNotEmpty
        ? match.blueAllianceTeamNums
        : match.blueAllianceTeamIds.map((id) => id.toString()).toList();

    // Format the scheduled time
    String? timeStr;
    if (match.scheduledTime != null) {
      timeStr = DateFormat('h:mm a').format(match.scheduledTime!.toLocal());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.shortName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: CupertinoColors.label),
                ),
                if (timeStr != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      timeStr,
                      style: const TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: _buildAllianceColumn(
                        redTeams,
                        CupertinoColors.systemRed,
                        isSplitScore && rScore < bScore)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '$finalScore',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                ),
                Expanded(
                    child: _buildAllianceColumn(
                        blueTeams,
                        CupertinoColors.systemBlue,
                        isSplitScore && bScore < rScore)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllianceColumn(List<String> teams, Color color, bool isDq) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var team in teams)
          Text(team,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        if (isDq)
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Text('⚠️ DQ',
                style: TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemOrange,
                    fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

// ---------- RANKINGS ----------

class _RankingsList extends ConsumerWidget {
  final Event event;
  const _RankingsList({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF49CAEB);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(eventsRepositoryProvider).getEventRankings(event.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style:
                      const TextStyle(color: CupertinoColors.destructiveRed)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No rankings available.',
                  style: TextStyle(color: CupertinoColors.secondaryLabel)));
        }

        final rankings = List<Map<String, dynamic>>.from(snapshot.data!);
        rankings.sort((a, b) {
          final r1 = a['rank'] as int? ?? 999;
          final r2 = b['rank'] as int? ?? 999;
          return r1.compareTo(r2);
        });

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('RANKINGS'),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: rankings.map((rankItem) {
                final teamMap = rankItem['team'] as Map<String, dynamic>;
                final teamNum = teamMap['name'] ?? '?';
                final teamId = teamMap['id'] as int;
                final rank = rankItem['rank'];
                final avgScore = rankItem['average_points'];

                return CupertinoListTile.notched(
                  leading: Text('$rank',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: CupertinoColors.systemGrey2)),
                  title: Text(teamNum,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  additionalInfo: Text('${avgScore ?? '-'} pts',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: primaryColor)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    final team = Team(
                      id: teamId,
                      number: teamNum,
                      name: teamMap['team_name'] ?? '',
                      eventId: event.id,
                    );
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) =>
                            TeamAtEventScreen(team: team, event: event)));
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ---------- SKILLS ----------

class _SkillsList extends ConsumerWidget {
  final Event event;
  const _SkillsList({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF49CAEB);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(eventsRepositoryProvider).getEventSkills(event.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style:
                      const TextStyle(color: CupertinoColors.destructiveRed)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No skills data available.',
                  style: TextStyle(color: CupertinoColors.secondaryLabel)));
        }

        // Group skills by team and aggregate scores
        final skillsRaw = snapshot.data!;
        final teamSkills = <int, _TeamSkillAggregate>{};

        for (final skill in skillsRaw) {
          final teamMap = skill['team'] as Map<String, dynamic>?;
          if (teamMap == null) continue;
          final teamId = teamMap['id'] as int;
          final teamNum = teamMap['name'] as String? ?? '?';
          final score = skill['score'] as int? ?? 0;
          final type = skill['type'] as String? ?? '';

          if (!teamSkills.containsKey(teamId)) {
            teamSkills[teamId] = _TeamSkillAggregate(
              teamId: teamId,
              teamNumber: teamNum,
            );
          }

          final agg = teamSkills[teamId]!;
          if (type == 'programming') {
            if (score > agg.programming) agg.programming = score;
          } else if (type == 'driver') {
            if (score > agg.driver) agg.driver = score;
          }
        }

        // Create sorted list by combined score
        final sortedTeams = teamSkills.values.toList()
          ..sort((a, b) => b.combinedScore.compareTo(a.combinedScore));

        // Assign ranks
        for (int i = 0; i < sortedTeams.length; i++) {
          sortedTeams[i].rank = i + 1;
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: sortedTeams.length,
          itemBuilder: (context, index) {
            final item = sortedTeams[index];
            return CupertinoListTile.notched(
              leading: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  shape: BoxShape.circle,
                ),
                child: Text('${item.rank}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: CupertinoColors.label)),
              ),
              title: Text(item.teamNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17)),
              subtitle: Text(
                  'Prog: ${item.programming}    Driver: ${item.driver}',
                  style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.combinedScore}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () {
                ref.read(teamSearchQueryProvider.notifier).state =
                    item.teamNumber;
                ref.read(bottomNavIndexProvider.notifier).state = 2;
              },
            );
          },
        );
      },
    );
  }
}

class _TeamSkillAggregate {
  final int teamId;
  final String teamNumber;
  int programming = 0;
  int driver = 0;
  int rank = 0;

  _TeamSkillAggregate({
    required this.teamId,
    required this.teamNumber,
  });

  int get combinedScore => programming + driver;
}

// ---------- AWARDS ----------

class _AwardsList extends ConsumerWidget {
  final Event event;
  const _AwardsList({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF49CAEB);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(eventsRepositoryProvider).getEventAwards(event.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style:
                      const TextStyle(color: CupertinoColors.destructiveRed)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No awards available.',
                  style: TextStyle(color: CupertinoColors.secondaryLabel)));
        }

        final awards = snapshot.data!;
        final displayItems = <CupertinoListTile>[];

        for (final award in awards) {
          final title = award['title'] ?? 'Award';
          final teamWinners = award['teamWinners'] as List? ?? [];

          if (teamWinners.isEmpty) {
            displayItems.add(CupertinoListTile.notched(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              leading: const Icon(CupertinoIcons.gift, color: primaryColor),
            ));
          } else {
            for (final w in teamWinners) {
              final teamMap = w['team'] as Map<String, dynamic>?;
              final num = teamMap?['name'] ?? 'Unknown';
              displayItems.add(CupertinoListTile.notched(
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                leading:
                    const Icon(CupertinoIcons.gift_fill, color: primaryColor),
                additionalInfo: Text(num,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16)),
              ));
            }
          }
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('AWARDS'),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: displayItems,
            ),
          ],
        );
      },
    );
  }
}
