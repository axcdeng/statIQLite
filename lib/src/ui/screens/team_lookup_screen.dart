import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/screens/events_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamLookupScreen extends ConsumerStatefulWidget {
  const TeamLookupScreen({super.key});

  @override
  ConsumerState<TeamLookupScreen> createState() => _TeamLookupScreenState();
}

class _TeamLookupScreenState extends ConsumerState<TeamLookupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Search State
  bool _isLoading = false;
  Team? _team;
  Map<String, dynamic>? _skills;
  Map<String, dynamic>? _awards;
  List<dynamic>? _events;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Sync manual search to provider so it knows current state
    ref.read(teamSearchQueryProvider.notifier).state = query;

    // Sync manual search to provider so it knows current state
    // We use a post-frame callback or just set it here to avoid conflicts?
    // Setting it here is fine as long as the listener doesn't cause a loop.
    // The listener checks if (next != _searchController.text).
    // Here we set provider = query. Listener sees next == query == text. No loop.
    ref.read(teamSearchQueryProvider.notifier).state = query;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _team = null;
      _skills = null;
      _awards = null;
      _events = null;
    });

    try {
      final repo = ref.read(teamsRepositoryProvider);

      // 1. Search for team
      final teams = await repo.searchTeams(query);

      if (teams.isEmpty) {
        setState(() {
          _errorMessage = 'Team not found';
          _isLoading = false;
        });
        return;
      }

      // Exact match preference, or first result
      final team = teams.firstWhere(
        (t) => t.number.toLowerCase() == query.toLowerCase(),
        orElse: () => teams.first,
      );

      // 2. Fetch Details in parallel
      final results = await Future.wait([
        repo.getTeamSkills(team.id),
        repo.getTeamAwards(team.id),
        repo.getTeamEvents(team.id),
      ]);

      if (mounted) {
        setState(() {
          _team = team;
          // Process skills (find highest robot/drivers skills)
          // RoboStem/RobotEvents usually gives list of skills entries.
          // We need to parse this for "World Skills Ranking" which might be in statiq or calculated.
          // For now, storing raw response.
          // Actually, getTeamSkills returns List<Map>, let's grab the composite if available.
          // _skills = results[0] as List<Map<String, dynamic>>; // dynamic casting issue likely
          // Simplified for now:
          _skills = (results[0] as List).isNotEmpty
              ? (results[0] as List).first as Map<String, dynamic>
              : null;

          // Awards count
          // _awards = results[1];

          // Events
          _events = results[2] as List<dynamic>;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error searching: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for search query changes from other screens (e.g. Favorites)
    ref.listen(teamSearchQueryProvider, (previous, next) {
      if (next != null && next.isNotEmpty && next != _searchController.text) {
        _searchController.text = next;
        _search();
        // Clear the provider so we don't re-trigger unnecessarily if we come back
        // ref.read(teamSearchQueryProvider.notifier).state = null;
        // actually better to leave it or clear it after search finishes,
        // but clearing here avoids loops.
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lookup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teams'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeamsTab(),
          const EventsListView(),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Team Number',
              hintText: 'e.g. 229V',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red))
          else if (_team != null)
            _buildTeamResultCard()
          else
            const Text('Enter a team number to search.',
                style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTeamResultCard() {
    final favoriteService = ref.watch(favoritesServiceProvider);
    final isFavorite = favoriteService.isTeamFavorite(_team!.number);

    // Parse Location
    // Assuming team.location is properly formatted from API, or we parse here.

    // Parse Skills
    // If statiq is available, use it. Otherwise try to parse from _skills list.
    var worldSkillsRank = _team!.statiq?['world_skills_rank'];
    var worldSkillsScore = _team!.statiq?['world_skills_score'];

    if (worldSkillsRank == null && _skills != null) {
      // logic to extract from _skills if needed, or leave as N/A
      // RoboStem might return 'rank' in the skills response
      worldSkillsRank = _skills!['rank'];
      worldSkillsScore = _skills!['score'];
    }

    final wsRankDisplay = worldSkillsRank?.toString() ?? 'N/A';
    final wsScoreDisplay = worldSkillsScore?.toString() ?? 'N/A';

    // Awards Count
    final awardsCount =
        _awards != null ? (_awards!['awards'] as List).length.toString() : '0';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: Link - Number - Star
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () async {
                    final url = Uri.parse(
                        'https://robotevents.com/teams/VIQRC/${_team!.number}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
                Text(
                  _team!.number,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                  onPressed: () async {
                    if (isFavorite) {
                      await favoriteService.removeFavoriteTeam(_team!.number);
                    } else {
                      await favoriteService.addFavoriteTeam(_team!.number);
                    }
                    setState(() {}); // Refresh local UI state
                  },
                ),
              ],
            ),
            const Divider(),
            // Stats Grid
            _buildStatRow('Name', _team!.name),
            _buildStatRow('Organization', _team!.organization ?? 'N/A'),
            _buildStatRow('Location', _team!.location ?? 'N/A'),
            const SizedBox(height: 10),
            _buildStatRow('World Skills Ranking', wsRankDisplay),
            _buildStatRow('World Skills Score', wsScoreDisplay),
            _buildStatRow('Awards Count', awardsCount),
            const SizedBox(height: 10),
            // Additional Stats
            if (_team!.statiq != null) ...[
              _buildStatRow(
                  'TrueSkill',
                  (_team!.statiq!['performance'] as num?)?.toStringAsFixed(2) ??
                      'N/A'),
              _buildStatRow('EPA',
                  (_team!.statiq!['epa'] as num?)?.toStringAsFixed(2) ?? 'N/A'),
            ],
            const SizedBox(height: 20),
            // Events Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to events list
                  // TODO: Push to Team Events Screen
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Events List Coming Soon')));
                },
                child: const Text('Events'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8), // Spacing
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
