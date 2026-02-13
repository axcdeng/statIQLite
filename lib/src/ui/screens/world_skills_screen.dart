import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class WorldSkillsScreen extends ConsumerStatefulWidget {
  const WorldSkillsScreen({super.key});

  @override
  ConsumerState<WorldSkillsScreen> createState() => _WorldSkillsScreenState();
}

class _WorldSkillsScreenState extends ConsumerState<WorldSkillsScreen> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(apiClientProvider).getGlobalSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Skills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _future = ref.read(apiClientProvider).getGlobalSkills();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final rank = item['rank'];
              final team = item['team'] as Map<String, dynamic>;
              final number = team['number'];
              final score = item['score'];
              final prog = item['programming'];
              final driver = item['driver'];

              return ListTile(
                leading: Text('#$rank',
                    style: Theme.of(context).textTheme.titleMedium),
                title: Text(number,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Prog: $prog | Driver: $driver'),
                trailing: Text(score.toString(),
                    style: Theme.of(context).textTheme.titleLarge),
              );
            },
          );
        },
      ),
    );
  }
}
