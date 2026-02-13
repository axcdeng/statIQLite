import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/routes.dart';

class RoboScoutIQApp extends StatelessWidget {
  const RoboScoutIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoboScout IQ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
