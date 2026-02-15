import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _robotEventsKeyController = TextEditingController();
  final _roboStemKeyController = TextEditingController();

  // Hardcoded seasons for now, as fetching them might require a valid API key first
  final Map<int, String> _seasons = {
    196: '2025-2026 Mix & Match',
    188: '2024-2025 Rapid Relay',
    181: '2023-2024 Full Volume',
    173: '2022-2023 Slapshot',
    156: '2021-2022 Pitching In',
  };

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _robotEventsKeyController.text = settings.robotEventsApiKey ?? '';
    _roboStemKeyController.text = settings.roboStemApiKey ?? '';
  }

  @override
  void dispose() {
    _robotEventsKeyController.dispose();
    _roboStemKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section: General
            _buildSectionHeader('General'),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    title: 'Primary Season',
                    trailing: Text(
                      _seasons[settings.primarySeasonId] ?? 'Unknown Season',
                      style: TextStyle(
                          color:
                              CupertinoColors.systemGrey.resolveFrom(context)),
                    ),
                    onTap: () => _showSeasonPicker(settings.primarySeasonId),
                  ),
                  _buildDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CupertinoSlidingSegmentedControl<ThemeMode>(
                      groupValue: settings.themeMode,
                      children: {
                        ThemeMode.light: Text('Light',
                            style: TextStyle(
                                color: settings.themeMode == ThemeMode.light
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null)),
                        ThemeMode.dark: Text('Dark',
                            style: TextStyle(
                                color: settings.themeMode == ThemeMode.dark
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null)),
                        ThemeMode.system: Text('System',
                            style: TextStyle(
                                color: settings.themeMode == ThemeMode.system
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null)),
                      },
                      onValueChanged: (mode) {
                        if (mode != null) {
                          settingsNotifier.setTheme(mode);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: API Configuration
            _buildSectionHeader('API Configuration'),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildTextFieldRow(
                    controller: _robotEventsKeyController,
                    label: 'RobotEvents Key',
                    placeholder: 'Enter API Key',
                    onChanged: (val) =>
                        settingsNotifier.setRobotEventsApiKey(val),
                  ),
                  _buildDivider(),
                  _buildTextFieldRow(
                    controller: _roboStemKeyController,
                    label: 'RoboSTEM Key',
                    placeholder: 'Enter API Key',
                    onChanged: (val) => settingsNotifier.setRoboStemApiKey(val),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                'Leave keys empty to use default shared keys (if available).',
                style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context)),
              ),
            ),

            const SizedBox(height: 24),

            // Section: Data Management
            _buildSectionHeader('Data Management'),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    title: 'Force Full Sync',
                    titleColor: primaryColor,
                    icon: CupertinoIcons.arrow_2_circlepath,
                    iconColor: primaryColor,
                    onTap: () {
                      ref.read(eventsRepositoryProvider).basicSync();
                      // Feedback
                    },
                  ),
                  _buildDivider(),
                  _buildListTile(
                    title: 'Purge All Data',
                    titleColor: CupertinoColors.destructiveRed,
                    icon: CupertinoIcons.trash,
                    iconColor: CupertinoColors.destructiveRed,
                    onTap: () => _confirmPurge(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Column(
              children: [
                Text(
                  '© RoboSTEM FOUNDATION INC. 2026',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          CupertinoColors.tertiaryLabel.resolveFrom(context)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data from RobotEvents API & RoboSTEM API',
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          CupertinoColors.tertiaryLabel.resolveFrom(context)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.secondaryLabel.resolveFrom(context)),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    Widget? trailing,
    Color? titleColor,
    IconData? icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: titleColor ?? CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.systemGrey3.resolveFrom(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldRow({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label.resolveFrom(context))),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              obscureText: true,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.right,
              decoration: null, // Remove default border
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 0,
      color: CupertinoColors.separator,
    );
  }

  void _showSeasonPicker(int currentSeasonId) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem:
                        _seasons.keys.toList().indexOf(currentSeasonId),
                  ),
                  onSelectedItemChanged: (index) {
                    final newSeasonId = _seasons.keys.elementAt(index);
                    // We need to access the notifier to call methods
                    ref.read(settingsProvider.notifier).setSeason(newSeasonId);
                  },
                  children: _seasons.values
                      .map((name) => Center(child: Text(name)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPurge(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Purge All Data?'),
        content: const Text(
            'This will delete all locally stored events, teams, and matches. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(localDbServiceProvider).clearAllData();
              Navigator.pop(context);
            },
            child: const Text('Purge'),
          ),
        ],
      ),
    );
  }
}
