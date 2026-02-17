import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class EventInfoScreen extends ConsumerStatefulWidget {
  final Event event;

  const EventInfoScreen({super.key, required this.event});

  @override
  ConsumerState<EventInfoScreen> createState() => _EventInfoScreenState();
}

class _EventInfoScreenState extends ConsumerState<EventInfoScreen> {
  late Event _event;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _fetchFullEventDetails();
  }

  Future<void> _fetchFullEventDetails() async {
    setState(() => _isLoading = true);
    try {
      final freshEvent =
          await ref.read(eventsRepositoryProvider).getEventById(_event.id);
      if (freshEvent != null && mounted) {
        setState(() {
          _event = freshEvent;
        });
      }
    } catch (e) {
      // print('Error fetching full event details: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamCount =
        ref.watch(teamsRepositoryProvider).getTeamsForEvent(_event.id).length;
    final divisionsCount = _event.divisions?.length ?? 1;
    final season = _shortenSeasonName(_event.seasonName ?? 'Unknown Season');
    final city = _event.city ?? 'Unknown City';
    final region = _event.region ?? 'Unknown Region';
    final country = _event.country ?? 'Unknown Country';

    // "MMM d, yyyy" format (e.g., Feb 14, 2026)
    final dateFormat = DateFormat.yMMMd();
    final startDateStr = dateFormat.format(_event.startDate);
    final endDateStr = dateFormat.format(_event.endDate);
    final dateStr = startDateStr == endDateStr
        ? startDateStr
        : '$startDateStr - $endDateStr';

    return CupertinoPageScaffold(
      // Use systemGroupedBackground for contrast with white cards (in light mode)
      // or grey cards (in dark mode).
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Event Info'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.link,
              color: Theme.of(context).colorScheme.primary),
          onPressed: () async {
            final url = Uri.parse(
                'https://www.robotevents.com/robot-competitions/vex-iq-competition/${_event.sku}.html');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header: Event Name
                // Explicitly using high-contrast color for visibility
                Text(
                  _event.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),

                // 2. Main Info Card
                _buildSectionCard(context, [
                  _buildInfoRow(
                      context, CupertinoIcons.calendar, 'Date', dateStr),
                  _buildDivider(context),
                  _buildInfoRow(context, CupertinoIcons.map, 'Location',
                      '$city, $region'),
                  _buildDivider(context),
                  _buildInfoRow(
                      context, CupertinoIcons.flag, 'Country', country),
                  _buildDivider(context),
                  _buildInfoRow(context, CupertinoIcons.game_controller,
                      'Season', season),
                ]),

                const SizedBox(height: 16),

                // 3. Stats Row (Split Cards)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(context, 'Teams', '$teamCount'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                          context, 'Divisions', '$divisionsCount'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: CupertinoColors.systemGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    // Ensure text wraps
                    color: CupertinoColors.label.resolveFrom(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: CupertinoColors.separator.resolveFrom(context),
    );
  }

  String _shortenSeasonName(String fullSeasonName) {
    // Regex to remove "VEX ... Competition" prefix but KEEP year and game name
    final regex = RegExp(
        r'^(?:VEX\s+(?:IQ\s+|V5\s+|U\s+|AI\s+)?(?:Robotics\s+Competition|Challenge)?)\s*',
        caseSensitive: false);

    return fullSeasonName.replaceAll(regex, '').trim();
  }
}
