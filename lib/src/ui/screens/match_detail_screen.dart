import 'package:flutter/cupertino.dart';
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Calculate prediction (Stub example)
    final prediction = RatingService.predictWinProbability(1500, 1500);
    final winChance = (prediction * 100).toStringAsFixed(1);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(match.name),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _AllianceCard(
                color: CupertinoColors.systemRed,
                teamIds: match.redAllianceTeamIds,
                score: match.redScore,
              ),
              const SizedBox(height: 12),
              _AllianceCard(
                color: CupertinoColors.systemBlue,
                teamIds: match.blueAllianceTeamIds,
                score: match.blueScore,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: CupertinoColors.separator.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Prediction (Red Win Chance)',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.secondaryLabel)),
                    const SizedBox(height: 8),
                    Text('$winChance%',
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1)),
                    const SizedBox(height: 8),
                    const Text('Based on deterministic rating model (Elo)',
                        style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                color: primaryColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.scoutingForm,
                    arguments: {'match': match},
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.doc_text_viewfinder),
                    SizedBox(width: 8),
                    Text('Scout This Match',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: teamIds
                .map((id) => Text('Team ID: $id',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16)))
                .toList(),
          ),
          Text(score?.toString() ?? '-',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
