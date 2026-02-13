import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final key = await secureStorage.getApiKey();
    if (key != null) {
      _apiKeyController.text = key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('RobotEvents API Key',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              hintText: 'Enter your API key',
              helperText: 'Get this from RobotEvents.com',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveApiKey,
            child: const Text('Save API Key'),
          ),
          const Divider(height: 40),
          const Text('Data Management',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Purge All Local Data'),
            onTap: _purgeData,
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Force Full Sync'),
            onTap: () {
              ref.read(eventsRepositoryProvider).basicSync();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync started in background')));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    if (_apiKeyController.text.isNotEmpty) {
      await secureStorage.saveApiKey(_apiKeyController.text.trim());
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('API Key Saved')));
    }
  }

  Future<void> _purgeData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purge Data?'),
        content: const Text(
            'This will delete all events, teams, matches, and scouting entries locally. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete All',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(localDbServiceProvider).clearAllData();
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Data Purged')));
    }
  }
}
