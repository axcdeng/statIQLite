import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/ui/screens/resources/game_manual_tab.dart';
import 'package:roboscout_iq/src/ui/screens/resources/score_calculator_tab.dart';
import 'package:roboscout_iq/src/ui/screens/resources/field_setup_tab.dart';
import 'package:roboscout_iq/src/ui/screens/resources/match_timer_tab.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  int _selectedTab = 0;

  static const _tabLabels = ['Manual', 'Calculator', 'Field', 'Timer'];
  static const _tabs = [
    GameManualTab(),
    ScoreCalculatorTab(),
    FieldSetupTab(),
    MatchTimerTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF49CAEB);

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Resources'),
          backgroundColor: CupertinoColors.systemGroupedBackground,
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
                    groupValue: _selectedTab,
                    children: {
                      for (int i = 0; i < _tabLabels.length; i++)
                        i: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Text(
                            _tabLabels[i],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _selectedTab == i
                                  ? CupertinoColors.white
                                  : CupertinoColors.label,
                            ),
                          ),
                        ),
                    },
                    onValueChanged: (int? value) {
                      if (value != null) {
                        setState(() => _selectedTab = value);
                      }
                    },
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: _tabs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
