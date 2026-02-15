import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart';
import 'package:roboscout_iq/src/ui/screens/event_divisions_screen.dart';
import 'package:roboscout_iq/src/ui/screens/events_list_screen.dart';
import 'package:roboscout_iq/src/utils/country_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamLookupScreen extends ConsumerStatefulWidget {
  const TeamLookupScreen({super.key});

  @override
  ConsumerState<TeamLookupScreen> createState() => _TeamLookupScreenState();
}

class _TeamLookupScreenState extends ConsumerState<TeamLookupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Search State
  bool _isLoading = false;
  Team? _team;
  Map<String, dynamic>? _worldSkillsData;
  // List<dynamic>? _events; // Not strictly needed unless we want to show count
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    ref.read(teamSearchQueryProvider.notifier).state = query;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _team = null;
      _worldSkillsData = null;
    });

    try {
      final repo = ref.read(teamsRepositoryProvider);

      // 1. Search for team (limit 1)
      final teams = await repo.searchTeams(query);

      if (teams.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Team not found';
            _isLoading = false;
          });
        }
        return;
      }

      final team = teams.first;

      // 2. Fetch World Skills Data (pass grade level for targeted search)
      final skillsData =
          await repo.getTeamSkillRank(team.number, gradeLevel: team.grade);

      if (mounted) {
        setState(() {
          _team = team;
          _worldSkillsData = skillsData;
          _isLoading = false;
        });
        // Add to history
        ref.read(historyServiceProvider).addTeamToHistory(team);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error searching: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    ref.listen(teamSearchQueryProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        // Ensure we are on the Teams tab
        if (_tabController.index != 0) {
          setState(() {
            _tabController.index = 0;
          });
        }

        if (next != _searchController.text) {
          _searchController.text = next;
          _search();
        }
      }
    });

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Lookup'),
          // Removed trailing link icon
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    thumbColor: primaryColor,
                    backgroundColor: CupertinoColors.tertiarySystemFill,
                    groupValue: _tabController.index,
                    children: {
                      0: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text('Teams',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 0
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
                      1: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text('Events',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _tabController.index == 1
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : CupertinoColors.secondaryLabel
                                          .resolveFrom(context)))),
                    },
                    onValueChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          _tabController.index = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: _tabController.index == 0
                    ? _buildTeamsTab()
                    : const EventsListView(showNavigationBar: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsTab() {
    final returnState = ref.watch(returnToEventProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (returnState != null) _buildReturnToEventBanner(returnState),
          Row(
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: 'Team Number (e.g. 229V)',
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                child: Icon(CupertinoIcons.clock, color: primaryColor),
                onPressed: () => _showHistory(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CupertinoActivityIndicator()
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(_errorMessage!,
                  style:
                      const TextStyle(color: CupertinoColors.destructiveRed)),
            )
          else if (_team != null)
            _buildTeamResultCard()
          else
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Text('Enter a team number to search.',
                  style: TextStyle(color: CupertinoColors.systemGrey2)),
            ),
        ],
      ),
    );
  }

  Widget _buildReturnToEventBanner(dynamic returnState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.arrow_left,
              color: CupertinoColors.systemBlue),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                ref.read(returnToEventProvider.notifier).state = null;
                // Try to get full event to check divisions
                Event? event;
                try {
                  event = await ref
                      .read(eventsRepositoryProvider)
                      .getEventById(returnState.eventId);
                } catch (e) {
                  print('Error fetching event for return: $e');
                }

                // Fallback if fetch fails (use basic info)
                event ??= Event(
                  id: returnState.eventId,
                  sku: '',
                  name: returnState.eventName,
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  programCode: 'VIQC',
                  venue: '',
                  location: '',
                );

                if (mounted) {
                  if (event.divisions != null && event.divisions!.length > 1) {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => EventDivisionsScreen(event: event!)));
                  } else {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => EventDetailScreen(
                            event: event!,
                            initiallySelectedTeam: returnState.team)));
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Return to Event',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemBlue)),
                  Text('Back to ${returnState.eventName} matches',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.xmark_circle_fill,
                size: 20, color: CupertinoColors.systemGrey),
            onPressed: () =>
                ref.read(returnToEventProvider.notifier).state = null,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamResultCard() {
    final favoriteService = ref.watch(favoritesServiceProvider);
    final isFavorite = favoriteService.isTeamFavorite(_team!.number);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Stats
    final worldRank = _worldSkillsData?['rank'];
    final worldScore = _worldSkillsData?['score'];
    final trueskill = _team!.statiq?['performance']; // "TrueSkill"
    final epa = _team!.statiq?['epa'];
    // Grade label: "MS" or "ES"
    final gradeLabel = _team!.grade == 'Elementary School'
        ? 'ES'
        : _team!.grade == 'Middle School'
            ? 'MS'
            : null;

    return Column(
      children: [
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Parse country from location for flag
                    Builder(builder: (context) {
                      String? country;
                      if (_team!.location != null &&
                          _team!.location!.isNotEmpty) {
                        final parts = _team!.location!.split(', ');
                        if (parts.isNotEmpty) {
                          country = parts.last;
                        }
                      }
                      final flag = CountryUtils.getFlagEmoji(country);
                      return Text('$flag ${_team!.number}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold));
                    }),
                    if (gradeLabel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(gradeLabel,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor)),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: Icon(CupertinoIcons.link,
                          color: primaryColor, size: 22),
                      onPressed: () async {
                        final url = Uri.parse(
                            'https://robotevents.com/teams/VIQRC/${_team!.number}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: Icon(
                        isFavorite
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: isFavorite
                            ? CupertinoColors.systemYellow
                            : primaryColor,
                        size: 22,
                      ),
                      onPressed: () async {
                        if (isFavorite) {
                          await favoriteService
                              .removeFavoriteTeam(_team!.number);
                        } else {
                          await favoriteService.addFavoriteTeam(_team!.number);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            _buildInfoRow('Name', _team!.name),
            if (_team!.organization != null)
              _buildInfoRow('Organization', _team!.organization!),
            if (_team!.location != null)
              _buildInfoRow('Location', _team!.location!),
            _buildInfoRow('World Skills Rank', worldRank?.toString() ?? 'N/A'),
            _buildInfoRow(
                'World Skills Score', worldScore?.toString() ?? 'N/A'),
            _buildInfoRow(
                'TrueSkill', (trueskill as num?)?.toStringAsFixed(2) ?? 'N/A'),
            _buildEpaRow((epa as num?)?.toStringAsFixed(2) ?? 'N/A'),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.calendar),
                SizedBox(width: 8),
                Text('View All Events'),
              ],
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AppRoutes.teamEvents, arguments: _team);
            },
          ),
        ),
      ],
    );
  }

  /// Custom info row with grey label and white value, allows wrapping.
  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: -0.4,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context))),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 17,
                color: CupertinoColors.label.resolveFrom(context),
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// EPA row with info icon tooltip.
  Widget _buildEpaRow(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'EPA per Match ',
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: -0.4,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context)),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('EPA (Expected Points Added)'),
                          content: const Text(
                              "Estimated Points Added per match. A metric to estimate a team's average contribution to the score."),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: const Icon(CupertinoIcons.info_circle,
                          size: 18, color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              color: CupertinoColors.label.resolveFrom(context),
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    final historyService = ref.read(historyServiceProvider);
    final recentTeams = historyService.getRecentTeams();

    if (recentTeams.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('No History'),
          content: const Text('Search for a team to see it here.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Recent Teams'),
        actions: recentTeams
            .map((team) => CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    _searchController.text = team.number;
                    _search();
                  },
                  child: Text('${team.number} - ${team.name}'),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
