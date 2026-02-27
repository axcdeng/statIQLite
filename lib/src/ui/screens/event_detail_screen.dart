import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:roboscout_iq/src/models/division.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/event_info_screen.dart';
import 'package:roboscout_iq/src/ui/screens/team_at_event_screen.dart';
import 'package:roboscout_iq/src/utils/country_utils.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;
  final Team? initiallySelectedTeam;
  final Division? division;

  const EventDetailScreen(
      {super.key,
      required this.event,
      this.initiallySelectedTeam,
      this.division});

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isFavorite = widget.event.sku != null &&
        ref.watch(favoritesServiceProvider).isEventFavorite(widget.event.sku!);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.event.name,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            if (widget.division != null)
              Text(widget.division!.name,
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context))),
          ],
        ),
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
              child: Icon(CupertinoIcons.info, color: primaryColor, size: 20),
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => EventInfoScreen(event: widget.event)));
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
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
                      1: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Matches',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 1
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
                      2: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Rankings',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 2
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
                      3: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Skills',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 3
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
                      4: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Text('Awards',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 4
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
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
                    _TeamsList(event: widget.event, division: widget.division),
                    _MatchesList(
                        event: widget.event, division: widget.division),
                    _RankingsList(
                        event: widget.event, division: widget.division),
                    _SkillsList(event: widget.event, division: widget.division),
                    _AwardsList(event: widget.event, division: widget.division),
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
  final Division? division;
  const _TeamsList({required this.event, this.division});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsRepo = ref.watch(teamsRepositoryProvider);
    // final primaryColor = Theme.of(context).colorScheme.primary;

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
                  leading: Builder(builder: (context) {
                    String? country;
                    if (team.location != null && team.location!.isNotEmpty) {
                      final parts = team.location!.split(', ');
                      if (parts.isNotEmpty) {
                        country = parts.last;
                      }
                    }
                    return Text(CountryUtils.getFlagEmoji(country),
                        style: const TextStyle(fontSize: 24));
                  }),
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
  final Division? division;
  const _MatchesList({required this.event, this.division});

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
        var matches = matchesRepo.getMatchesForEvent(widget.event.id);

        if (widget.division != null) {
          matches = matches
              .where((m) => m.divisionId == widget.division!.id)
              .toList();
        }

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
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: CupertinoColors.label.resolveFrom(context)),
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

class _RankingsList extends ConsumerStatefulWidget {
  final Event event;
  final Division? division;
  const _RankingsList({required this.event, this.division});

  @override
  ConsumerState<_RankingsList> createState() => _RankingsListState();
}

class _RankingsListState extends ConsumerState<_RankingsList> {
  int _selectedSubTab = 0; // 0 for Rankings, 1 for Finals

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isFinals = _selectedSubTab == 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedSubTab,
              children: {
                0: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Rankings', style: TextStyle(fontSize: 13))),
                1: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Finals', style: TextStyle(fontSize: 13))),
              },
              onValueChanged: (val) {
                if (val != null) setState(() => _selectedSubTab = val);
              },
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: isFinals
                ? ref
                    .read(eventsRepositoryProvider)
                    .getFinalistRankings(widget.event.id)
                : ref
                    .read(eventsRepositoryProvider)
                    .getEventRankings(widget.event.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(
                            color: CupertinoColors.destructiveRed)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text(
                        isFinals
                            ? 'No finalist rankings available.'
                            : 'No rankings available.',
                        style: const TextStyle(
                            color: CupertinoColors.secondaryLabel)));
              }

              var rankings = List<Map<String, dynamic>>.from(snapshot.data!);

              if (widget.division != null) {
                rankings = rankings
                    .where((r) => r['divisionId'] == widget.division!.id)
                    .toList();
              }

              rankings.sort((a, b) {
                final r1 = a['rank'] as int? ?? 999;
                final r2 = b['rank'] as int? ?? 999;
                return r1.compareTo(r2);
              });

              // Pre-fetch matches if we are in finals to find scores
              return FutureBuilder<List<MatchModel>>(
                future: isFinals
                    ? () async {
                        final matchesRepo = ref.read(matchesRepositoryProvider);
                        await matchesRepo.fetchMatches(widget.event.id);
                        return matchesRepo
                            .getMatchesForEvent(widget.event.id)
                            .where((m) => m.isFinals)
                            .toList();
                      }()
                    : Future.value([]),
                builder: (context, matchSnapshot) {
                  final finalsMatches = matchSnapshot.data ?? [];

                  final List<Widget> listItems = [];

                  if (isFinals) {
                    // Group by rank
                    final grouped = <int, List<Map<String, dynamic>>>{};
                    for (final r in rankings) {
                      final rank = r['rank'] as int? ?? 0;
                      grouped.putIfAbsent(rank, () => []).add(r);
                    }

                    final sortedRanks = grouped.keys.toList()..sort();

                    for (final rank in sortedRanks) {
                      final allianceTeams = grouped[rank]!;
                      final teamNums = allianceTeams
                          .map((t) => (t['team']?['name'] as String?) ?? '')
                          .where((n) => n.isNotEmpty)
                          .toSet();

                      // Fallback to match score if API score is nul/zero
                      var score = allianceTeams.first['score'] ??
                          allianceTeams.first['points'] ??
                          allianceTeams.first['average_points'];

                      MatchModel? foundMatch;
                      if (finalsMatches.isNotEmpty) {
                        for (final m in finalsMatches) {
                          final matchTeams = {
                            ...m.redAllianceTeamNums,
                            ...m.blueAllianceTeamNums
                          };
                          // Check if this match contains all teams in this alliance
                          if (teamNums.every((n) => matchTeams.contains(n))) {
                            foundMatch = m;
                            if (score == null || score == 0) {
                              score = m.redScore ?? m.blueScore;
                            }
                            break;
                          }
                        }
                      }

                      // Relist teams to ensure correct order/color if match found
                      final List<Map<String, dynamic>> orderedTeams =
                          List.from(allianceTeams);
                      if (foundMatch != null) {
                        orderedTeams.sort((a, b) {
                          final numA = a['team']?['name'] ?? '';
                          // If numA is in red alliance, it should come first (return -1)
                          if (foundMatch!.redAllianceTeamNums.contains(numA)) {
                            return -1;
                          }
                          return 1;
                        });
                      }

                      listItems.add(CupertinoListTile.notched(
                        leading: Text('$rank',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: CupertinoColors.systemGrey2)),
                        title: Row(
                          children: [
                            for (int i = 0; i < orderedTeams.length; i++) ...[
                              Text(
                                (orderedTeams[i]['team']?['name'] ?? '?'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: i == 0
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.systemBlue,
                                ),
                              ),
                              if (i < orderedTeams.length - 1)
                                const Text(' ', style: TextStyle(fontSize: 17)),
                            ],
                          ],
                        ),
                        additionalInfo: Text('${score ?? '-'} pts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          // Navigate to the first team for now
                          final teamMap = orderedTeams.first['team']
                              as Map<String, dynamic>;
                          final teamNum = teamMap['name'] ?? '?';
                          final teamId = teamMap['id'] as int;
                          final team = Team(
                            id: teamId,
                            number: teamNum,
                            name: teamMap['team_name'] ?? '',
                            eventId: widget.event.id,
                          );
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => TeamAtEventScreen(
                                  team: team, event: widget.event)));
                        },
                      ));
                    }
                  } else {
                    listItems.addAll(rankings.map((rankItem) {
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          final team = Team(
                            id: teamId,
                            number: teamNum,
                            name: teamMap['team_name'] ?? '',
                            eventId: widget.event.id,
                          );
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => TeamAtEventScreen(
                                  team: team, event: widget.event)));
                        },
                      );
                    }));
                  }

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      CupertinoListSection.insetGrouped(
                        header:
                            Text(isFinals ? 'FINALIST RANKINGS' : 'RANKINGS'),
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: listItems,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------- SKILLS ----------

class _SkillsList extends ConsumerWidget {
  final Event event;
  final Division? division;
  const _SkillsList({required this.event, this.division});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
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
        var skillsRaw = snapshot.data!;

        if (division != null) {
          // Note: Skills might be shared, but if we have division data, we can filter.
          // User requested explicit text saying skills are shared.
          // But if the API returns division-specific skills list, we might have duplicates?
          // Usually skills are global to the event.
          // Let's filter if divisionId is present, otherwise show all.
          // BUT: "in Skills tab add a small info section (thin) that says Skills are shared between all divisions."
          // This implies we should maybe NOT filter completely, or at least show the message.
          // If I filter, I might hide skills done in other divisions if they are tracked that way?
          // RobotEvents usually aggregates skills for the whole event.
          // However, my ApiClient injects divisionId from where it fetched it.
          // If I fetch skills from Division A endpoint, do I get skills from Division B?
          // Usually no.
          // So if we have multiple divisions, we probably want to see ALL skills for the event?
          // "Skills are shared between all divisions" suggests the list should include everyone.
          // So I will NOT filter by division here, but I WILL add the info section.
        }

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

        return Column(
          children: [
            if (division != null)
              Container(
                width: double.infinity,
                color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.info_circle_fill,
                        size: 14, color: CupertinoColors.systemYellow),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Skills are shared between all divisions.',
                        style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.label.resolveFrom(context)),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: sortedTeams.length,
                itemBuilder: (context, index) {
                  final item = sortedTeams[index];
                  return CupertinoListTile.notched(
                    leading: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: CupertinoColors.secondarySystemGroupedBackground
                            .resolveFrom(context),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${item.rank}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  CupertinoColors.label.resolveFrom(context))),
                    ),
                    title: Text(item.teamNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    subtitle: Text(
                        'Prog: ${item.programming}    Driver: ${item.driver}',
                        style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context))),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.combinedScore}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    onTap: () {
                      final teamNum = item.teamNumber;
                      final teamRepo = ref.read(teamsRepositoryProvider);
                      // Try to find team locally, otherwise construct a partial Team model
                      // to avoid a full API fetch for now (the team screen will handle it)
                      Team? team = teamRepo.findLocalTeamByNumber(teamNum);

                      team ??= Team(
                        id: item.teamId,
                        number: teamNum,
                        name:
                            '', // We don't have the full name here easily, but the screen handles it
                        eventId: event.id,
                      );

                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) =>
                              TeamAtEventScreen(team: team!, event: event)));
                    },
                  );
                },
              ),
            ),
          ],
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
  final Division? division;
  const _AwardsList({required this.event, this.division});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
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

        final awards = List<Map<String, dynamic>>.from(snapshot.data!);

        // Sort awards by title priority
        awards.sort((a, b) {
          final t1 = (a['title'] as String? ?? '').toLowerCase();
          final t2 = (b['title'] as String? ?? '').toLowerCase();

          int getPriority(String title) {
            if (title.contains('excellence')) return 0;
            if (title.contains('champion')) return 1;
            if (title.contains('design')) return 2;
            if (title.contains('2nd place')) return 3;
            if (title.contains('3rd place')) return 4;
            if (title.contains('skills champion')) return 5;
            if (title.contains('skills 2nd')) return 6;
            if (title.contains('skills 3rd')) return 7;
            if (title.contains('judges')) return 8;
            if (title.contains('innovate')) return 9;
            if (title.contains('think')) return 10;
            if (title.contains('amaze')) return 11;
            if (title.contains('build')) return 12;
            if (title.contains('create')) return 13;
            if (title.contains('energy')) return 14;
            if (title.contains('sportsmanship')) return 15;
            return 100;
          }

          final p1 = getPriority(t1);
          final p2 = getPriority(t2);

          if (p1 != p2) return p1.compareTo(p2);
          return t1.compareTo(t2);
        });

        final displayItems = <CupertinoListTile>[];

        for (final award in awards) {
          final title = award['title'] ?? 'Award';
          final teamWinners = award['teamWinners'] as List? ?? [];
          final qualifications = award['qualifications'] as List? ?? [];
          final qualifiesToWorld = qualifications
              .any((q) => q.toString().toLowerCase().contains('world'));

          Widget titleWidget;
          if (qualifiesToWorld) {
            titleWidget = Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: title),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Icon(CupertinoIcons.globe,
                          size: 16, color: primaryColor),
                    ),
                  ),
                ],
              ),
              maxLines: null,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w600),
            );
          } else {
            titleWidget = Text(title,
                maxLines: null,
                softWrap: true,
                style: const TextStyle(fontWeight: FontWeight.w600));
          }

          if (teamWinners.isEmpty) {
            displayItems.add(CupertinoListTile.notched(
              title: titleWidget,
              leading: const Icon(CupertinoIcons.gift,
                  color: CupertinoColors.systemGrey),
            ));
          } else {
            for (final w in teamWinners) {
              final teamMap = w['team'] as Map<String, dynamic>?;
              final num = teamMap?['name'] ?? 'Unknown';
              final teamId = teamMap?['id'] as int?;
              displayItems.add(CupertinoListTile.notched(
                title: titleWidget,
                leading: Icon(CupertinoIcons.gift_fill, color: primaryColor),
                additionalInfo: Text(num,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16)),
                trailing: const CupertinoListTileChevron(),
                onTap: teamId == null
                    ? null
                    : () {
                        final teamRepo = ref.read(teamsRepositoryProvider);
                        Team? team = teamRepo.findLocalTeamByNumber(num);

                        team ??= Team(
                          id: teamId,
                          number: num,
                          name: '',
                          eventId: event.id,
                        );

                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (_) =>
                                TeamAtEventScreen(team: team!, event: event)));
                      },
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
