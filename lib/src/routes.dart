import 'package:flutter/material.dart';
import 'package:roboscout_iq/src/models/event_model.dart';
import 'package:roboscout_iq/src/models/match_model.dart';
import 'package:roboscout_iq/src/models/team_model.dart';
import 'package:roboscout_iq/src/ui/screens/event_detail_screen.dart';
import 'package:roboscout_iq/src/ui/screens/events_list_screen.dart';
import 'package:roboscout_iq/src/ui/screens/exports_screen.dart';
import 'package:roboscout_iq/src/ui/screens/match_detail_screen.dart';
import 'package:roboscout_iq/src/ui/screens/scouting_form_screen.dart';
import 'package:roboscout_iq/src/ui/screens/settings_screen.dart';
import 'package:roboscout_iq/src/ui/screens/splash_screen.dart';
import 'package:roboscout_iq/src/ui/screens/team_detail_screen.dart';
import 'package:roboscout_iq/src/ui/screens/world_skills_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String eventsList = '/events';
  static const String eventDetail = '/event_detail';
  static const String teamDetail = '/team_detail';
  static const String matchDetail = '/match_detail';
  static const String scoutingForm = '/scouting_form';
  static const String exports = '/exports';
  static const String settings = '/settings';
  static const String worldSkills = '/world_skills';
  static const String favorites = '/favorites';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case eventsList:
        return MaterialPageRoute(builder: (_) => const EventsListScreen());
      case eventDetail:
        final event = routeSettings.arguments as Event?; // TODO: Handle null/id
        return MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event!));
      case teamDetail:
        final team = routeSettings.arguments as Team?;
        return MaterialPageRoute(builder: (_) => TeamDetailScreen(team: team!));
      case matchDetail:
        final match = routeSettings.arguments as MatchModel?;
        return MaterialPageRoute(
            builder: (_) => MatchDetailScreen(match: match!));
      case scoutingForm:
        // Pass arguments like eventId, matchId, teamId, or an existing entry
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => ScoutingFormScreen(args: args));
      case exports:
        return MaterialPageRoute(builder: (_) => const ExportsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case worldSkills:
        return MaterialPageRoute(builder: (_) => const WorldSkillsScreen());
      // Favorites will be part of the main tab view, but adding route just in case
      case favorites:
        return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Favorites'))));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child:
                          Text('No route defined for ${routeSettings.name}')),
                ));
    }
  }
}
