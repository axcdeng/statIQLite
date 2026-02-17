import 'package:flutter/cupertino.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart';

class EventDivisionsScreen extends StatelessWidget {
  final Event event;

  const EventDivisionsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final divisions = event.divisions ?? [];
    // Sort by order
    divisions.sort((a, b) => a.order.compareTo(b.order));

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(event.name),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a Division',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navLargeTitleTextStyle
                    .copyWith(fontSize: 22),
              ),
            ),
            CupertinoListSection.insetGrouped(
              children: divisions.map((division) {
                return CupertinoListTile.notched(
                  title: Text(division.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => EventDetailScreen(
                          event: event,
                          division: division,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
