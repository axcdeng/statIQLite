import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';

class RoboScoutIQApp extends ConsumerWidget {
  const RoboScoutIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF49CAEB);
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      key: ValueKey(settings.themeMode),
      title: 'RoboScout IQ',
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: '.SF Pro Text',
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: '.SF Pro Text',
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.black,
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: primaryColor,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
