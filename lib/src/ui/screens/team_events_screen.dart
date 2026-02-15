import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart'; // For MatchTile

class TeamEventsScreen extends ConsumerStatefulWidget {
  final Team team;
  const TeamEventsScreen({super.key, required this.team});

  @override
  ConsumerState<TeamEventsScreen> createState() => _TeamEventsScreenState();
}

class _TeamEventsScreenState extends ConsumerState<TeamEventsScreen> {
  List<Event> _currentSeasonEvents = [];
  List<Event> _allEvents = [];
  bool _isLoading = true;
  bool _showAllSeasons = false;
  bool _isLoadingPrevious = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCurrentSeasonEvents();
  }

  Future<void> _fetchCurrentSeasonEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await ref.read(teamsRepositoryProvider).getTeamEvents(
          widget.team.id,
          seasonId: ref.read(settingsProvider).primarySeasonId);
      events.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
      if (mounted) {
        setState(() {
          _currentSeasonEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAllEvents() async {
    setState(() => _isLoadingPrevious = true);

    try {
      final events =
          await ref.read(teamsRepositoryProvider).getTeamEvents(widget.team.id);
      events.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
      if (mounted) {
        setState(() {
          _allEvents = events;
          _showAllSeasons = true;
          _isLoadingPrevious = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrevious = false;
        });
      }
    }
  }

  List<Event> get _displayedEvents =>
      _showAllSeasons ? _allEvents : _currentSeasonEvents;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF49CAEB);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.team.number} Events'),
        backgroundColor: CupertinoColors.black.withOpacity(0.9),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text('Error: $_errorMessage',
                          style: const TextStyle(
                              color: CupertinoColors.destructiveRed)))
                  : _displayedEvents.isEmpty
                      ? const Center(
                          child: Text('No events found for this team.',
                              style: TextStyle(color: Color(0xFF8E8E93))))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: _displayedEvents.length +
                              (_showAllSeasons ? 0 : 1), // +1 for the button
                          itemBuilder: (context, index) {
                            // "Load previous seasons" button at the top
                            if (!_showAllSeasons && index == 0) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: CupertinoButton(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(10),
                                  onPressed: _isLoadingPrevious
                                      ? null
                                      : _fetchAllEvents,
                                  child: _isLoadingPrevious
                                      ? const CupertinoActivityIndicator()
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.clock,
                                                size: 16, color: primaryColor),
                                            SizedBox(width: 8),
                                            Text('Load Previous Seasons',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                ),
                              );
                            }

                            final eventIndex =
                                _showAllSeasons ? index : index - 1;
                            return _EventExpansionTile(
                                event: _displayedEvents[eventIndex],
                                team: widget.team);
                          },
                        ),
        ),
      ),
    );
  }
}

class _EventExpansionTile extends ConsumerStatefulWidget {
  final Event event;
  final Team team;

  const _EventExpansionTile({required this.event, required this.team});

  @override
  ConsumerState<_EventExpansionTile> createState() =>
      _EventExpansionTileState();
}

class _EventExpansionTileState extends ConsumerState<_EventExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(widget.event.startDate);
    const primaryColor = Color(0xFF49CAEB);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header (tappable)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.event.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: CupertinoColors.white)),
                        const SizedBox(height: 4),
                        Text(dateStr,
                            style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: primaryColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded)
            _EventDetails(event: widget.event, team: widget.team),
        ],
      ),
    );
  }
}

class _EventDetails extends ConsumerWidget {
  final Event event;
  final Team team;

  const _EventDetails({required this.event, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesRepo = ref.watch(matchesRepositoryProvider);
    final teamsRepo = ref.watch(teamsRepositoryProvider);
    const primaryColor = Color(0xFF49CAEB);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigate to full event button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => EventDetailScreen(event: event)));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.arrow_right_circle,
                      size: 16, color: primaryColor),
                  SizedBox(width: 6),
                  Text('View Full Event',
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('MATCHES',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 0.5)),
          ),
          FutureBuilder<List<MatchModel>>(
            future: matchesRepo
                .fetchMatches(event.id)
                .then((_) => matchesRepo.getMatchesForEvent(event.id)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CupertinoActivityIndicator()));
              }
              final matches = snapshot.data ?? [];
              final teamMatches = matches
                  .where((m) =>
                      m.redAllianceTeamIds.contains(team.id) ||
                      m.blueAllianceTeamIds.contains(team.id))
                  .toList();

              if (teamMatches.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('No matches found.',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                );
              }

              return Column(
                children: teamMatches.map((m) => MatchTile(match: m)).toList(),
              );
            },
          ),

          const SizedBox(height: 12),

          // Awards Section
          FutureBuilder<List<Map<String, dynamic>>>(
            future: teamsRepo.getTeamAwards(team.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final allAwards = snapshot.data ?? [];
              final eventAwards =
                  allAwards.where((a) => a['event']['id'] == event.id).toList();

              if (eventAwards.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text('AWARDS',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E8E93),
                            letterSpacing: 0.5)),
                  ),
                  ...eventAwards.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.gift_fill,
                                color: primaryColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(a['title'] ?? 'Award',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.white)),
                            ),
                          ],
                        ),
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
