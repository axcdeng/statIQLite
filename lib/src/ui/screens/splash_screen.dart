import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/routes.dart';
import 'package:roboscout_iq/src/services/local_db_service.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Basic init logic
    // LocalDbService.init() is called in main.dart

    // Check for API Key
    final secureStorage = ref.read(secureStorageServiceProvider);
    final apiKey = await secureStorage.getApiKey();

    if (!mounted) return;

    if (apiKey == null) {
      // Go to settings or prompt for key?
      // For now, go to Events List, user can set key in settings
      Navigator.of(context).pushReplacementNamed(AppRoutes.eventsList);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.eventsList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text('RoboScout IQ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
