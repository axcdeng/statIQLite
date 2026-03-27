import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/resources/game_manual_tab.dart';
import 'package:roboscout_iq/src/ui/screens/resources/score_calculator_tab.dart';
import 'package:roboscout_iq/src/ui/screens/resources/field_setup_tab.dart';
import 'package:roboscout_iq/src/ui/screens/resources/match_timer_tab.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  static const _tabLabels = ['Timer', 'Calculator', 'Field', 'Manual'];

  List<Widget> _getTabs(int selectedTab) => [
        MatchTimerTab(isActive: selectedTab == 0),
        const ScoreCalculatorTab(),
        const FieldSetupTab(),
        const GameManualTab(),
      ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedTab = ref.watch(resourcesTabProvider);
    final tabs = _getTabs(selectedTab);

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Resources'),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Subtab selector
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    thumbColor: primaryColor,
                    backgroundColor: CupertinoColors.tertiarySystemFill,
                    groupValue: selectedTab,
                    children: {
                      for (int i = 0; i < _tabLabels.length; i++)
                        i: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Text(
                            _tabLabels[i],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: selectedTab == i
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                            ),
                          ),
                        ),
                    },
                    onValueChanged: (int? value) {
                      if (value != null) {
                        ref.read(resourcesTabProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: IndexedStack(
                  index: selectedTab,
                  children: tabs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
