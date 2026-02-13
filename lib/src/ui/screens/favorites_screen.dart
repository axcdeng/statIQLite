import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesService = ref.watch(favoritesServiceProvider);
    // Trigger rebuild when favorites change (assuming check is cheap or service notifies)
    // Note: Use a Stream or ValueListenable in Service for better reactivity if needed.
    // For now, simply reading the list. Ideally, watch a provider that exposes the list.

    // We need the service to notify listeners. The current service implementation uses Hive directly
    // but doesn't extend ChangeNotifier or StateNotifier.
    // To make it reactive, we should probably wrap the lists in a StateProvider or StreamProvider.
    // OR, just for now, assume the parent/tab view rebuilds or we rely on explicit refresh.
    // Let's rely on `ref.watch(favoritesServiceProvider)` assuming if we mutate it we invalidate it?
    // No, standard Provider doesn't auto-notify on inner mutation.
    // We need to fix the Service to be reactive, OR use ValueListenableBuilder on the Box.

    // Re-implementing with Hive ValueListenableBuilder for reactivity
    // We need access to the Box. The service wraps it.
    // Let's modify FavoritesService in the next step to expose the listenable or box.
    // For now, I'll assume we can get the list re-fetched.

    final favTeams = favoritesService.getFavoriteTeams();
    final favEvents = favoritesService.getFavoriteEvents();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Teams'),
              Tab(text: 'Events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Favorite Teams List
            favTeams.isEmpty
                ? const Center(child: Text('No favorite teams'))
                : ListView.builder(
                    itemCount: favTeams.length,
                    itemBuilder: (context, index) {
                      final teamNum = favTeams[index];
                      return ListTile(
                        title: Text(teamNum),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to Lookup Tab and Search
                          ref.read(teamSearchQueryProvider.notifier).state =
                              teamNum;
                          // Lookup is index 2 in the _screens list in EventsListScreen
                          // 0: Favorites, 1: World Skills, 2: Lookup, 3: Settings
                          ref.read(bottomNavIndexProvider.notifier).state = 2;
                        },
                      );
                    },
                  ),
            // Favorite Events List
            favEvents.isEmpty
                ? const Center(child: Text('No favorite events'))
                : ListView.builder(
                    itemCount: favEvents.length,
                    itemBuilder: (context, index) {
                      final eventSku = favEvents[index];
                      return ListTile(
                        title: Text(eventSku),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to event detail
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
