import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/scout_entry_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:uuid/uuid.dart';

class ScoutingFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? args;
  const ScoutingFormScreen({super.key, this.args});

  @override
  ConsumerState<ScoutingFormScreen> createState() => _ScoutingFormScreenState();
}

class _ScoutingFormScreenState extends ConsumerState<ScoutingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamController = TextEditingController();
  final _notesController = TextEditingController();

  // Example fields
  int _autoPoints = 0;
  int _driverPoints = 0;

  @override
  void initState() {
    super.initState();
    if (widget.args != null) {
      if (widget.args!.containsKey('team')) {
        _teamController.text = widget.args!['team'].toString();
      }
      // Load other args
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Scout Match'),
        backgroundColor: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: 0.8),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveEntry,
          child: Text('Save',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text('TEAM',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.secondaryLabel)),
              ),
              CupertinoTextField(
                controller: _teamController,
                placeholder: 'e.g. 229V',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text('AUTONOMOUS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.secondaryLabel)),
              ),
              _CounterField(
                label: 'Auto Points',
                value: _autoPoints,
                onChanged: (v) => setState(() => _autoPoints = v),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text('DRIVER CONTROL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.secondaryLabel)),
              ),
              _CounterField(
                label: 'Driver Points',
                value: _driverPoints,
                onChanged: (v) => setState(() => _driverPoints = v),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text('NOTES',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.secondaryLabel)),
              ),
              CupertinoTextField(
                controller: _notesController,
                placeholder: 'Add any observations...',
                maxLines: 4,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(scoutingRepositoryProvider);
      final entry = ScoutEntry(
        id: const Uuid().v4(),
        eventId: 0, // TODO: Get from args
        matchId: 0, // TODO: Get from args
        teamNumber: _teamController.text,
        timestamp: DateTime.now(),
        data: {
          'autoPoints': _autoPoints,
          'driverPoints': _driverPoints,
        },
        notes: _notesController.text,
        scoutName: 'User', // TODO: Get from settings
      );

      repo.saveEntry(entry);
      Navigator.pop(context);
    }
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterField(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.minus_circle,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => onChanged(value > 0 ? value - 1 : 0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('$value',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.plus_circle,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}
