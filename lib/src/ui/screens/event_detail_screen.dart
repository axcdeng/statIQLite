import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/team_at_event_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch data for this event on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamsRepositoryProvider).fetchTeams(widget.event.id);
      ref.read(matchesRepositoryProvider).fetchMatches(widget.event.id);
      // Rankings/Awards are not yet in repo fetch logic, assuming API calls in widgets for now or add to repo?
      // Repo has getEventRankings/Awards methods but they return Futures, not updating a store?
      // Let's use Futures directly in the tabs for now.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Teams'),
            Tab(text: 'Matches'),
            Tab(text: 'Rankings'),
            Tab(text: 'Awards'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.exports);
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TeamsList(eventId: widget.event.id),
          _MatchesList(eventId: widget.event.id),
          _RankingsList(eventId: widget.event.id),
          _AwardsList(eventId: widget.event.id),
        ],
      ),
    );
  }
}

class _TeamsList extends ConsumerWidget {
  final int eventId;
  const _TeamsList({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsRepo = ref.watch(teamsRepositoryProvider);
    return ValueListenableBuilder<Box<Team>>(
      valueListenable: teamsRepo.watchTeams(),
      builder: (context, box, _) {
        final teams = teamsRepo.getTeamsForEvent(eventId);
        if (teams.isEmpty)
          return const Center(child: Text('No teams or loading...'));

        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return ListTile(
              title: Text(team.number),
              subtitle: Text(team.name),
              onTap: () {
                // Open Team At Event Screen (Matches for this team at this event)
                // Or navigate to global team detail? User said: "clicking into these teams should show their matches of the event"
                // Check implementation plan: "[NEW] TeamAtEventScreen.dart"
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        TeamAtEventScreen(team: team, eventId: eventId)));
              },
            );
          },
        );
      },
    );
  }
}

class _MatchesList extends ConsumerWidget {
  final int eventId;
  const _MatchesList({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesRepo = ref.watch(matchesRepositoryProvider);
    return ValueListenableBuilder<Box<MatchModel>>(
      valueListenable: matchesRepo.watchMatches(),
      builder: (context, box, _) {
        final matches = matchesRepo.getMatchesForEvent(eventId);
        if (matches.isEmpty)
          return const Center(child: Text('No matches loaded.'));

        return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchTile(match: match);
            });
      },
    );
  }
}

class MatchTile extends StatelessWidget {
  final MatchModel match;
  const MatchTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final redTeams = match.redAllianceTeamNums.isNotEmpty
        ? match.redAllianceTeamNums
        : match.redAllianceTeamIds.map((id) => id.toString()).toList();

    final blueTeams = match.blueAllianceTeamNums.isNotEmpty
        ? match.blueAllianceTeamNums
        : match.blueAllianceTeamIds.map((id) => id.toString()).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // match name
            SizedBox(
                width: 60,
                child: Text(
                    match.name
                        .replaceAll('Match', '')
                        .replaceAll('Qualifier', 'Q')
                        .replaceAll('Practice', 'P')
                        .replaceAll('Final', 'F')
                        .trim(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis)),

            // Left (Red-ish)
            Expanded(
                child: Column(
              children: redTeams
                  .map((t) => Text(t,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)))
                  .toList(),
            )),

            // Score
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${match.redScore ?? 0} - ${match.blueScore ?? 0}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // Right (Blue-ish)
            Expanded(
                child: Column(
              children: blueTeams
                  .map((t) => Text(t,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)))
                  .toList(),
            )),
          ],
        ),
      ),
    );
  }
}

class _RankingsList extends ConsumerWidget {
  final int eventId;
  const _RankingsList({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(eventsRepositoryProvider).getEventRankings(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator.adaptive());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text('No rankings available.'));

        final rankings = snapshot.data!;

        return ListView.builder(
          itemCount: rankings.length,
          itemBuilder: (context, index) {
            final rank = rankings[index];
            // "Rank on left, team # and name stacked, Avg score on right"
            final teamMap = rank['team'] as Map<String, dynamic>;
            final teamNum =
                teamMap['name'] ?? '?'; // API 'name' is usually number
            final teamName =
                teamMap['id'].toString(); // We might not have name here easily

            // Actually 'team' obj usually has {id, name(number), team_name(name)}.

            return ListTile(
              leading: CircleAvatar(child: Text('${rank['rank']}')),
              title: Text(teamNum),
              subtitle: Text('Score: ${rank['average_points'] ?? 0}'),
              trailing: Text('WP: ${rank['wins']}'),
            );
          },
        );
      },
    );
  }
}

class _AwardsList extends ConsumerWidget {
  final int eventId;
  const _AwardsList({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(eventsRepositoryProvider).getEventAwards(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator.adaptive());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text('No awards available.'));

        final awards = snapshot.data!;
        return ListView.builder(
          itemCount: awards.length,
          itemBuilder: (context, index) {
            final award = awards[index];
            final title = award['title'] ?? 'Award';
            final teamWinners = award['teamWinners'] as List? ?? [];
            if (teamWinners.isEmpty) return ListTile(title: Text(title));

            return Column(
              children: teamWinners.map<Widget>((w) {
                final teamMap = w['team'] as Map<String, dynamic>?;
                final num = teamMap?['name'] ?? 'Unknown';

                return ListTile(
                  title: Text(title),
                  trailing: Text(num,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Go to team matches?
                    // Verify implementation plan
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
