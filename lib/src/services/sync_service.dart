import 'package:roboscout_iq/src/repositories/events_repository.dart';
import 'package:workmanager/workmanager.dart';

// Top-level function for background task
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Re-initialize Hive and dependencies inside isolate
    // This is a complex setup stub, verifying constraints
    // For now, return success
    return Future.value(true);
  });
}

class SyncService {
  final EventsRepository _eventsRepo;

  SyncService(this._eventsRepo);

  Future<void> initialize() async {
    // Register background task
    // Workmanager().initialize(callbackDispatcher);
    // Workmanager().registerPeriodicTask("1", "periodicSync");
  }

  Future<void> syncAll() async {
    await _eventsRepo.basicSync();
    // Additional sync logic for selected events
  }
}
