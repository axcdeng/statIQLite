import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class WorldSkillsScreen extends ConsumerStatefulWidget {
  const WorldSkillsScreen({super.key});

  @override
  ConsumerState<WorldSkillsScreen> createState() => _WorldSkillsScreenState();
}

class _WorldSkillsScreenState extends ConsumerState<WorldSkillsScreen> {
  // Cache for skills data
  List<Map<String, dynamic>> _msSkills = [];
  List<Map<String, dynamic>> _esSkills = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _gradeLevel = 'Middle School'; // Default selection

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final client = ref.read(apiClientProvider);

      // Fetch both MS and ES in parallel
      final results = await Future.wait([
        client.getGlobalSkills(gradeLevel: 'Middle School'),
        client.getGlobalSkills(gradeLevel: 'Elementary School'),
      ]);

      if (mounted) {
        setState(() {
          // Use List.from to ensure we have mutable lists
          _msSkills = List<Map<String, dynamic>>.from(results[0]);
          _esSkills = List<Map<String, dynamic>>.from(results[1]);

          // Explicitly sort by rank, handling potential type mismatches
          int sortRank(Map<String, dynamic> a, Map<String, dynamic> b) {
            final r1 = a['rank'] is num
                ? (a['rank'] as num).toInt()
                : int.tryParse(a['rank'].toString()) ?? 999;
            final r2 = b['rank'] is num
                ? (b['rank'] as num).toInt()
                : int.tryParse(b['rank'].toString()) ?? 999;
            return r1.compareTo(r2);
          }

          _msSkills.sort(sortRank);
          _esSkills.sort(sortRank);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _gradeLevel == 'Middle School' ? _msSkills : _esSkills;
    const primaryColor = Color(0xFF49CAEB);

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('World Skills'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.refresh, color: primaryColor),
            onPressed: _fetchSkills,
          ),
          backgroundColor: CupertinoColors.black.withOpacity(0.9),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<String>(
                    thumbColor: primaryColor,
                    backgroundColor: CupertinoColors.tertiarySystemFill,
                    groupValue: _gradeLevel,
                    children: {
                      'Middle School': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('Middle School',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _gradeLevel == 'Middle School'
                                    ? CupertinoColors.white
                                    : CupertinoColors.label)),
                      ),
                      'Elementary School': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('Elementary School',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _gradeLevel == 'Elementary School'
                                    ? CupertinoColors.white
                                    : CupertinoColors.label)),
                      ),
                    },
                    onValueChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _gradeLevel = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text('Error: $_errorMessage'))
                        : currentList.isEmpty
                            ? const Center(child: Text('No data found'))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: currentList.length,
                                itemBuilder: (context, index) =>
                                    _buildSkillTile(
                                        currentList[index], context),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillTile(Map<String, dynamic> item, BuildContext context) {
    final rank = item['rank'];
    final team = item['team'] as Map<String, dynamic>;
    final number = team['number'];
    final name = team['name'] ?? '';
    final score = item['score'];
    final prog = item['programming'];
    final driver = item['driver'];
    const primaryColor = Color(0xFF49CAEB);

    return CupertinoListTile.notched(
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemGrey6,
          shape: BoxShape.circle,
        ),
        child: Text('$rank',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: CupertinoColors.label)),
      ),
      title: Row(
        children: [
          Text(number,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text('Prog: $prog    Driver: $driver',
          style: const TextStyle(fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20), // Pill shape
        ),
        child: Text(
          '$score',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: primaryColor,
            fontSize: 18,
          ),
        ),
      ),
      onTap: () {
        ref.read(teamSearchQueryProvider.notifier).state = number;
        ref.read(bottomNavIndexProvider.notifier).state = 2;
      },
    );
  }
}
