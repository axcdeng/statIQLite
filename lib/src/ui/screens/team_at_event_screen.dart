import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart'; // For MatchTile
import 'package:roboscout_iq/src/routes.dart';

class TeamAtEventScreen extends ConsumerWidget {
  final Team team;
  final int eventId;

  const TeamAtEventScreen(
      {super.key, required this.team, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesService = ref.watch(favoritesServiceProvider);
    final isFavorite = favoritesService.isTeamFavorite(team.number);
    final matchesRepo = ref.watch(matchesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Team ${team.number}'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: () {
              if (isFavorite) {
                favoritesService.removeFavoriteTeam(team.number).then((_) {
                  ref.refresh(favoritesServiceProvider);
                });
              } else {
                favoritesService.addFavoriteTeam(team.number).then((_) {
                  ref.refresh(favoritesServiceProvider);
                });
              }
              // Force rebuild
              (context as Element).markNeedsBuild();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_outward),
            onPressed: () {
              // Navigate to Lookup (Team Detail)
              Navigator.of(context)
                  .pushNamed(AppRoutes.teamDetail, arguments: team);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Context Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                    child: Text('Matches at Event ID: $eventId',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                // Maybe fetch specific ranking for this team?
              ],
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<Box<MatchModel>>(
              valueListenable: matchesRepo.watchMatches(),
              builder: (context, box, _) {
                final allMatches = matchesRepo.getMatchesForEvent(eventId);
                // Filter matches where this team is playing
                // Filter matches where this team is playing
                final teamMatches = allMatches.where((m) {
                  return m.redAllianceTeamIds.contains(team.id) ||
                      m.blueAllianceTeamIds.contains(team.id);
                }).toList();

                if (teamMatches.isEmpty) {
                  return const Center(
                      child: Text(
                          'No matches found for this team at this event.'));
                }

                return ListView.builder(
                  itemCount: teamMatches.length,
                  itemBuilder: (context, index) {
                    return MatchTile(match: teamMatches[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
