import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:roboscout_iq/src/services/local_db_service.dart';
import 'package:roboscout_iq/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical DB boxes (Settings) before app starts
  await LocalDbService.init();

  final container = ProviderContainer();

  runApp(UncontrolledProviderScope(
      container: container, child: const RoboScoutIQApp()));
}
