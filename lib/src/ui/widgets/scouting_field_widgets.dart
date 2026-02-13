import 'package:flutter/material.dart';

class CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const CounterField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        IconButton(icon: const Icon(Icons.remove), onPressed: () => onChanged(value > 0 ? value - 1 : 0)),
        Text('$value'),
        IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(value + 1)),
      ],
    );
  }
}

// Add other custom form widgets here (e.g., AllianceSelector, Checkbox, etc.)
