import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class TeamDetailScreen extends ConsumerWidget {
  final Team team;
  const TeamDetailScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesService = ref.watch(favoritesServiceProvider);
    final isFavorite = favoritesService.isTeamFavorite(team.number);

    // Parse statiq data
    final statiq = team.statiq;
    final trueskill = statiq?['performance'] as num?;
    final epa = statiq?['epa'] as num?;

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
              // Force rebuild to update icon immediately if provider doesn't auto-update (it should if watching)
              (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(team.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(team.school ?? team.organization ?? 'Unknown Org',
                style: Theme.of(context).textTheme.titleMedium),
            if (team.location != null)
              Text(team.location!,
                  style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            const Divider(),
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (trueskill != null)
              ListTile(
                title: const Text('TrueSkill (Performance)'),
                trailing: Text(trueskill.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            if (epa != null)
              ListTile(
                title: const Text('EPA'),
                trailing: Text(epa.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            // Placeholder for World Skills if we don't have it in the team object
            const ListTile(
              title: Text('World Skills Ranking'),
              trailing: Text('Check Leaderboard'),
            ),

            const Divider(),
            // TODO: Display match history and stats
            const Text('Match History (Coming Soon)'),
          ],
        ),
      ),
    );
  }
}
