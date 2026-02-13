import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(match.name),
        subtitle: Text('R: ${match.redScore} - B: ${match.blueScore}'),
        onTap: onTap,
      ),
    );
  }
}
