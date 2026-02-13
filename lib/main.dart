import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roboscout_iq/src/app.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';
import 'package:roboscout_iq/src/state/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  // Initialize Hive and Local DB
  await LocalDbService.init();

  // Initialize Favorites
  final container = ProviderContainer();
  await container.read(favoritesServiceProvider).init();

  runApp(UncontrolledProviderScope(
      container: container, child: const RoboScoutIQApp()));
}
