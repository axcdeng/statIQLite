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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scout Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _teamController,
              decoration: const InputDecoration(labelText: 'Team Number'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            const Text('Autonomous',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _CounterField(
              label: 'Auto Points',
              value: _autoPoints,
              onChanged: (v) => setState(() => _autoPoints = v),
            ),
            const Divider(),
            const Text('Driver Control',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _CounterField(
              label: 'Driver Points',
              value: _driverPoints,
              onChanged: (v) => setState(() => _driverPoints = v),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
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
    return Row(
      children: [
        Text(label),
        const Spacer(),
        IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => onChanged(value > 0 ? value - 1 : 0)),
        Text('$value'),
        IconButton(
            icon: const Icon(Icons.add), onPressed: () => onChanged(value + 1)),
      ],
    );
  }
}
