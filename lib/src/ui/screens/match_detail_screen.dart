import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/team_at_event_screen.dart';

class MatchDetailScreen extends ConsumerWidget {
  final MatchModel match;
  final Event event;

  const MatchDetailScreen(
      {super.key, required this.match, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Format the scheduled time
    String dateStr = 'No time scheduled';
    if (match.scheduledTime != null) {
      dateStr = DateFormat('EEEE, MMM d  h:mm a')
          .format(match.scheduledTime!.toLocal());
    }

    final redTeams = match.redAllianceTeamNums.isNotEmpty
        ? match.redAllianceTeamNums
        : match.redAllianceTeamIds.map((id) => id.toString()).toList();

    final blueTeams = match.blueAllianceTeamNums.isNotEmpty
        ? match.blueAllianceTeamNums
        : match.blueAllianceTeamIds.map((id) => id.toString()).toList();

    final rankingsFuture =
        ref.watch(eventsRepositoryProvider).getEventRankings(event.id);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Match Details'),
      ),
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: FutureBuilder<List<Map<String, dynamic>>>(
              future: rankingsFuture,
              builder: (context, snapshot) {
                final rankings = snapshot.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Match Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              match.longName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.label
                                    .resolveFrom(context)
                                    .withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (match.field != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Field: ${match.field}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Score Card
                      if (match.isScored) _buildScoreCard(context, match),

                      const SizedBox(height: 24),

                      // Alliances
                      if (redTeams.isNotEmpty)
                        _buildAllianceSection(context, ref, 'RED ALLIANCE',
                            redTeams, CupertinoColors.systemRed, rankings),

                      if (redTeams.isNotEmpty && blueTeams.isNotEmpty)
                        const SizedBox(height: 20),

                      if (blueTeams.isNotEmpty)
                        _buildAllianceSection(context, ref, 'BLUE ALLIANCE',
                            blueTeams, CupertinoColors.systemBlue, rankings),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, MatchModel match) {
    final rScore = match.redScore ?? 0;
    final bScore = match.blueScore ?? 0;
    final isDq = rScore != bScore;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(
            context,
            'RED',
            isDq && rScore < bScore ? 0 : rScore,
            CupertinoColors.systemRed,
            isDq && rScore < bScore,
          ),
          Container(
              height: 40,
              width: 1,
              color: CupertinoColors.separator.resolveFrom(context)),
          _buildScoreItem(
            context,
            'BLUE',
            isDq && bScore < rScore ? 0 : bScore,
            CupertinoColors.systemBlue,
            isDq && bScore < rScore,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
      BuildContext context, String label, int score, Color color, bool isDq) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.8),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        if (isDq)
          const Text('⚠️ DQ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemYellow)),
      ],
    );
  }

  Widget _buildAllianceSection(
      BuildContext context,
      WidgetRef ref,
      String title,
      List<String> teamNums,
      Color color,
      List<Map<String, dynamic>> rankings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...teamNums
            .map((num) => _buildTeamCard(context, ref, num, color, rankings)),
      ],
    );
  }

  Widget _buildTeamCard(BuildContext context, WidgetRef ref, String teamNum,
      Color allianceColor, List<Map<String, dynamic>> rankings) {
    final teamsRepo = ref.read(teamsRepositoryProvider);
    final team = teamsRepo.findLocalTeamByNumber(teamNum);
    final primaryColor = Theme.of(context).colorScheme.primary;

    int? rank;
    if (rankings.isNotEmpty) {
      try {
        final rankItem = rankings
            .firstWhere((r) => r['team']?['name'] == teamNum, orElse: () => {});
        rank = rankItem['rank'] as int?;
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => TeamAtEventScreen(
                team: team ??
                    Team(id: 0, number: teamNum, name: '', eventId: event.id),
                event: event)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        teamNum,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (rank != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Rank #$rank',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Icon(CupertinoIcons.search,
                        color: primaryColor, size: 22),
                    onPressed: () {
                      ref.read(teamSearchQueryProvider.notifier).state =
                          teamNum;
                      ref.read(returnToEventProvider.notifier).state =
                          ReturnToEventState(
                        eventId: event.id,
                        eventName: event.name,
                        team: team ??
                            Team(
                                id: 0,
                                number: teamNum,
                                name: '',
                                eventId: event.id),
                      );
                      ref.read(bottomNavIndexProvider.notifier).state =
                          2; // Lookup tab
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
              if (team != null && team.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (team != null &&
                  team.organization != null &&
                  team.organization!.isNotEmpty)
                _buildTeamDetailRow(
                    context, CupertinoIcons.group, team.organization!),
              if (team != null &&
                  team.location != null &&
                  team.location!.isNotEmpty)
                _buildTeamDetailRow(
                    context, CupertinoIcons.location, team.location!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDetailRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: CupertinoColors.label
                  .resolveFrom(context)
                  .withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.label
                    .resolveFrom(context)
                    .withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
