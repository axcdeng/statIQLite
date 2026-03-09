import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // for Icons
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:roboscout_iq/src/models/score_entry.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';

class ScoreCalculatorTab extends StatefulWidget {
  const ScoreCalculatorTab({super.key});

  @override
  State<ScoreCalculatorTab> createState() => _ScoreCalculatorTabState();
}

class _ScoreCalculatorTabState extends State<ScoreCalculatorTab> {
  // Score state
  int _connectedPins = 0;
  int _connectedBeams = 0;
  int _twoColorStacks = 0;
  int _threeColorStacks = 0;
  int _matchingGoalOrBeam = 0;
  int _standoffGoal = 0;
  int _clearedStartingPins = 0;
  int _robotsContacting = 0;

  int get _totalScore {
    int total = 0;
    total += _connectedPins * 1;
    total += _connectedBeams * 10;
    total += _twoColorStacks * 5;
    total += _threeColorStacks * 15;
    total += _matchingGoalOrBeam * 10;
    total += _standoffGoal * 10;
    total += _clearedStartingPins * 2;
    total += _robotsContacting * 2;
    return total;
  }

  void _resetAll() {
    setState(() {
      _connectedPins = 0;
      _connectedBeams = 0;
      _twoColorStacks = 0;
      _threeColorStacks = 0;
      _matchingGoalOrBeam = 0;
      _standoffGoal = 0;
      _clearedStartingPins = 0;
      _robotsContacting = 0;
    });
  }

  Future<void> _saveScore() async {
    final entry = ScoreEntry(
      connectedPins: _connectedPins,
      connectedBeams: _connectedBeams,
      twoColorStacks: _twoColorStacks,
      threeColorStacks: _threeColorStacks,
      matchingGoalOrBeam: _matchingGoalOrBeam,
      standoffGoal: _standoffGoal,
      clearedStartingPins: _clearedStartingPins,
      robotsContacting: _robotsContacting,
      date: DateTime.now(),
      totalScore: _totalScore,
    );

    await LocalDbService().scoreEntriesBox.add(entry);

    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Score Saved'),
          content: Text('Total Score: $_totalScore'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }

  void _showHistory() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const ScoreHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Scoring items data
    final items = [
      _ScoreItem('Connected Pins', '1 pt', _connectedPins, 0, 36,
          (v) => _connectedPins = v),
      _ScoreItem('Connected Beams', '10 pts', _connectedBeams, 0, 2,
          (v) => _connectedBeams = v),
      _ScoreItem('2-Color Stacks', '5 pts', _twoColorStacks, 0, 20,
          (v) => _twoColorStacks = v),
      _ScoreItem('3-Color Stacks', '15 pts', _threeColorStacks, 0, 13,
          (v) => _threeColorStacks = v),
      _ScoreItem('Matching / Beam', '10 pts', _matchingGoalOrBeam, 0, 19,
          (v) => _matchingGoalOrBeam = v),
      _ScoreItem('Standoff Goal', '10 pts', _standoffGoal, 0, 3,
          (v) => _standoffGoal = v),
      _ScoreItem('Cleared Pins', '2 pts', _clearedStartingPins, 0, 4,
          (v) => _clearedStartingPins = v),
      _ScoreItem('Robot Contact', '2 pts', _robotsContacting, 0, 2,
          (v) => _robotsContacting = v),
    ];

    return Scaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Top Bar: Score + Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // History Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showHistory,
                  child:
                      Icon(CupertinoIcons.clock, color: primaryColor, size: 26),
                ),

                // Total Score
                Column(
                  children: [
                    Text(
                      'TOTAL SCORE',
                      style: TextStyle(
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '$_totalScore',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),

                // Save & Reset
                Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _saveScore,
                      child: Icon(CupertinoIcons.floppy_disk,
                          color: primaryColor, size: 26),
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _resetAll,
                      child: const Icon(CupertinoIcons.trash,
                          color: CupertinoColors.destructiveRed, size: 26),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Grid Layout
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55, // Taller cards to prevent overflow
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_ScoreItem item) {
    final bool isMax = item.value >= item.max;
    final bool isMin = item.value <= item.min;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // Reduced top space
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              item.label,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.pointsLabel,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 11,
            ),
          ),

          const Spacer(),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Minus
              GestureDetector(
                onTap: isMin
                    ? null
                    : () => setState(() => item.onChanged(item.value - 1)),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMin
                        ? CupertinoColors.tertiarySystemFill
                        : CupertinoColors.secondarySystemFill,
                  ),
                  child: Icon(
                    CupertinoIcons.minus,
                    size: 18,
                    color: isMin
                        ? CupertinoColors.quaternaryLabel.resolveFrom(context)
                        : CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),

              // Value
              SizedBox(
                width: 32,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${item.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),

              // Plus
              GestureDetector(
                onTap: isMax
                    ? null
                    : () => setState(() => item.onChanged(item.value + 1)),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMax
                        ? CupertinoColors.tertiarySystemFill
                        : Theme.of(context).colorScheme.primary, // Active color
                  ),
                  child: Icon(
                    CupertinoIcons.add,
                    size: 18,
                    color: isMax
                        ? CupertinoColors.quaternaryLabel.resolveFrom(context)
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced bottom space
        ],
      ),
    );
  }
}

class _ScoreItem {
  final String label;
  final String pointsLabel;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  _ScoreItem(this.label, this.pointsLabel, this.value, this.min, this.max,
      this.onChanged);
}

class ScoreHistoryScreen extends StatelessWidget {
  const ScoreHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      appBar: CupertinoNavigationBar(
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        middle: const Text('Score History'),
        leading: CupertinoNavigationBarBackButton(
            color: Theme.of(context).colorScheme.primary),
      ),
      body: ValueListenableBuilder<Box<ScoreEntry>>(
        valueListenable: LocalDbService().scoreEntriesBox.listenable(),
        builder: (context, box, _) {
          final entries = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No saved scores yet.',
                style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context)),
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Dismissible(
                key: Key(entry.key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: CupertinoColors.destructiveRed,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(CupertinoIcons.trash, color: Colors.white),
                ),
                onDismissed: (direction) {
                  entry.delete(); // HiveObject delete
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemGroupedBackground
                        .resolveFrom(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      'Total Score: ${entry.totalScore}',
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMd().add_jm().format(entry.date),
                      style: TextStyle(
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context)),
                    ),
                    trailing: Icon(CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey2.resolveFrom(context),
                        size: 16),
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('Score Details'),
                          content: Column(
                            children: [
                              _detailRow('Connected Pins', entry.connectedPins),
                              _detailRow(
                                  'Connected Beams', entry.connectedBeams),
                              _detailRow(
                                  '2-Color Stacks', entry.twoColorStacks),
                              _detailRow(
                                  '3-Color Stacks', entry.threeColorStacks),
                              _detailRow(
                                  'Matching / Beam', entry.matchingGoalOrBeam),
                              _detailRow('Standoff Goal', entry.standoffGoal),
                              _detailRow(
                                  'Cleared Pins', entry.clearedStartingPins),
                              _detailRow(
                                  'Robot Contact', entry.robotsContacting),
                              const Divider(color: CupertinoColors.systemGrey),
                              Text(
                                'Total: ${entry.totalScore}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Close'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
