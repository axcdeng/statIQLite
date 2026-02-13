import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/repositories/events_repository.dart';
import 'package:roboscout_iq/src/repositories/matches_repository.dart';
import 'package:roboscout_iq/src/repositories/scouting_repository.dart';
import 'package:roboscout_iq/src/repositories/teams_repository.dart';
import 'package:roboscout_iq/src/services/api_client.dart';
import 'package:roboscout_iq/src/services/export_service.dart';
import 'package:roboscout_iq/src/services/favorites_service.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';
import 'package:roboscout_iq/src/services/rating_service.dart';
import 'package:roboscout_iq/src/services/secure_storage_service.dart';
import 'package:roboscout_iq/src/services/sync_service.dart';

// Services
final localDbServiceProvider = Provider((ref) => LocalDbService());
final ratingServiceProvider = Provider((ref) => RatingService());
final exportServiceProvider = Provider((ref) => ExportService());
final favoritesServiceProvider = Provider((ref) => FavoritesService());
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());
final apiClientProvider =
    Provider((ref) => ApiClient(ref.read(secureStorageServiceProvider)));

// Repositories
final eventsRepositoryProvider = Provider((ref) => EventsRepository(
      ref.read(apiClientProvider),
      ref.read(localDbServiceProvider),
    ));

final teamsRepositoryProvider = Provider((ref) => TeamsRepository(
      ref.read(apiClientProvider),
      ref.read(localDbServiceProvider),
    ));

final matchesRepositoryProvider = Provider((ref) => MatchesRepository(
      ref.read(apiClientProvider),
      ref.read(localDbServiceProvider),
    ));

final scoutingRepositoryProvider = Provider((ref) => ScoutingRepository(
      ref.read(localDbServiceProvider),
    ));

// Sync
final syncServiceProvider = Provider((ref) => SyncService(
      ref.read(eventsRepositoryProvider),
    ));

// Navigation State
final bottomNavIndexProvider =
    StateProvider<int>((ref) => 1); // Default to Events/Lookup
final teamSearchQueryProvider = StateProvider<String?>((ref) => null);
