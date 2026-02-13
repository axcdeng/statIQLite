import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/models/team_model.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback? onTap;

  const TeamCard({super.key, required this.team, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${team.number} ${team.name}'),
        subtitle: Text('Rank: ${team.worldRank ?? "-"}'),
        onTap: onTap,
      ),
    );
  }
}
