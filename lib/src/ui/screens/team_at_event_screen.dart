import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart'; // For MatchTile

import 'package:roboscout_iq/src/models/event_model.dart'; // Make sure Event is imported
import 'package:roboscout_iq/src/utils/country_utils.dart';

class TeamAtEventScreen extends ConsumerWidget {
  final Team team;
  final Event event; // Changed from int eventId

  const TeamAtEventScreen({super.key, required this.team, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesService = ref.watch(favoritesServiceProvider);
    final isFavorite = favoritesService.isTeamFavorite(team.number);
    final matchesRepo = ref.watch(matchesRepositoryProvider);
    final eventId = event.id; // Convenience
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Builder(builder: (context) {
            String? country;
            if (team.location != null && team.location!.isNotEmpty) {
              final parts = team.location!.split(', ');
              if (parts.isNotEmpty) {
                country = parts.last;
              }
            }
            final flag = CountryUtils.getFlagEmoji(country);
            return Text('$flag ${team.number}');
          }),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
                  color:
                      isFavorite ? CupertinoColors.systemYellow : primaryColor,
                ),
                onPressed: () {
                  if (isFavorite) {
                    favoritesService.removeFavoriteTeam(team.number);
                  } else {
                    favoritesService.addFavoriteTeam(team.number);
                  }
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.arrow_up_right_square,
                    color: primaryColor),
                onPressed: () {
                  ref.read(teamSearchQueryProvider.notifier).state =
                      team.number;
                  ref.read(returnToEventProvider.notifier).state =
                      ReturnToEventState(
                    eventId: event.id,
                    eventName: event.name,
                    team: team,
                  );
                  ref.read(bottomNavIndexProvider.notifier).state = 2;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<Box<MatchModel>>(
                  valueListenable: matchesRepo.watchMatches(),
                  builder: (context, box, _) {
                    final allMatches = matchesRepo.getMatchesForEvent(eventId);
                    final teamMatches = allMatches.where((m) {
                      return m.redAllianceTeamIds.contains(team.id) ||
                          m.blueAllianceTeamIds.contains(team.id);
                    }).toList();

                    if (teamMatches.isEmpty) {
                      return const Center(
                          child: Text('No matches found for this team.',
                              style: TextStyle(
                                  color: CupertinoColors
                                      .systemGrey2))); // Brightened
                    }

                    // Sort: Qualifiers first (round 2), then finals, then by match number
                    teamMatches.sort((a, b) {
                      // Qualifiers (round == 2) should come before Finals
                      if (a.isQualifier && !b.isQualifier) return -1;
                      if (!a.isQualifier && b.isQualifier) return 1;
                      // Within same type, sort by round, instance, matchNum
                      if (a.round != b.round) return a.round.compareTo(b.round);
                      if (a.instance != b.instance)
                        return a.instance.compareTo(b.instance);
                      return a.matchNum.compareTo(b.matchNum);
                    });

                    return ListView.separated(
                      itemCount: teamMatches.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return MatchTile(match: teamMatches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
