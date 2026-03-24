import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/ui/theme.dart';

class RoboScoutIQApp extends ConsumerWidget {
  const RoboScoutIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Use themeMode from settings
    return MaterialApp(
      title: 'statIQ Lite',
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return CupertinoTheme(
          data: MaterialBasedCupertinoThemeData(
            materialTheme: Theme.of(context),
          ),
          child: child!,
        );
      },
    );
  }
}
