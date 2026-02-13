import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/services/rating_service.dart';

class MatchDetailScreen extends ConsumerWidget {
  final MatchModel match;
  const MatchDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate prediction (Stub example)
    // In a real app, you'd fetch ratings for all teams in alliance
    final prediction = RatingService.predictWinProbability(
        1500, 1500); // 50% for equal ratings
    final winChance = (prediction * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: Text(match.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _AllianceCard(
              color: Colors.red,
              teamIds: match.redAllianceTeamIds,
              score: match.redScore,
            ),
            const SizedBox(height: 10),
            _AllianceCard(
              color: Colors.blue,
              teamIds: match.blueAllianceTeamIds,
              score: match.blueScore,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Prediction (Red Win Chance)',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('$winChance%',
                        style: Theme.of(context).textTheme.displayLarge),
                    const Text('Based on deterministic rating model (Elo)',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.scoutingForm,
                  arguments: {'match': match},
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Scout This Match'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            )
          ],
        ),
      ),
    );
  }
}

class _AllianceCard extends StatelessWidget {
  final Color color;
  final List<int> teamIds;
  final int? score;

  const _AllianceCard({required this.color, required this.teamIds, this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamIds
                  .map((id) => Text('Team ID: $id',
                      style: const TextStyle(fontWeight: FontWeight.bold)))
                  .toList(),
            ),
            Text(score?.toString() ?? '-',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
