import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart'; // For MatchTile
import 'package:roboscout_iq/src/ui/screens/event_divisions_screen.dart';

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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.team.number} Events'),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text('Error: $_errorMessage',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)))
                  : _displayedEvents.isEmpty
                      ? Center(
                          child: Text('No events found for this team.',
                              style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .color
                                          ?.withValues(alpha: 0.6) ??
                                      CupertinoColors.systemGrey)))
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
                                  color: CupertinoColors.tertiarySystemFill,
                                  borderRadius: BorderRadius.circular(10),
                                  onPressed: _isLoadingPrevious
                                      ? null
                                      : _fetchAllEvents,
                                  child: _isLoadingPrevious
                                      ? const CupertinoActivityIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.clock,
                                                size: 16, color: primaryColor),
                                            const SizedBox(width: 8),
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
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
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: CupertinoColors.label
                                    .resolveFrom(context))),
                        const SizedBox(height: 4),
                        Text(dateStr,
                            style: TextStyle(
                                color: CupertinoColors.systemGrey
                                    .resolveFrom(context),
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

class _EventDetails extends ConsumerStatefulWidget {
  final Event event;
  final Team team;

  const _EventDetails({required this.event, required this.team});

  @override
  ConsumerState<_EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends ConsumerState<_EventDetails> {
  late Future<List<MatchModel>> _matchesFuture;
  late Future<List<Map<String, dynamic>>> _awardsFuture;

  @override
  void initState() {
    super.initState();
    final matchesRepo = ref.read(matchesRepositoryProvider);
    final teamsRepo = ref.read(teamsRepositoryProvider);

    _matchesFuture = matchesRepo
        .fetchMatches(widget.event.id)
        .then((_) => matchesRepo.getMatchesForEvent(widget.event.id));
    _awardsFuture = teamsRepo.getTeamAwards(widget.team.id);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                if (widget.event.divisions != null &&
                    widget.event.divisions!.length > 1) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) =>
                          EventDivisionsScreen(event: widget.event)));
                } else {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => EventDetailScreen(event: widget.event)));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.arrow_right_circle,
                      size: 16, color: primaryColor),
                  const SizedBox(width: 6),
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
                    color: CupertinoColors.systemGrey,
                    letterSpacing: 0.5)),
          ),
          FutureBuilder<List<MatchModel>>(
            future: _matchesFuture,
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
                      m.redAllianceTeamIds.contains(widget.team.id) ||
                      m.blueAllianceTeamIds.contains(widget.team.id))
                  .toList();

              if (teamMatches.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('No matches found.',
                      style: TextStyle(
                          color: CupertinoColors.systemGrey, fontSize: 13)),
                );
              }

              return Column(
                children: teamMatches
                    .map((m) => MatchTile(match: m, event: widget.event))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 12),

          // Awards Section
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _awardsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final allAwards = snapshot.data ?? [];
              final eventAwards = allAwards
                  .where((a) => a['event']['id'] == widget.event.id)
                  .toList();

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
                            color: CupertinoColors.systemGrey,
                            letterSpacing: 0.5)),
                  ),
                  ...eventAwards.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.gift_fill,
                                color: primaryColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(a['title'] ?? 'Award',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.label
                                          .resolveFrom(context))),
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
