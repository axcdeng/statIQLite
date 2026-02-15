import 'package:flutter/cupertino.dart';
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
import 'package:roboscout_iq/src/ui/screens/resources_screen.dart';
import 'package:roboscout_iq/src/ui/screens/world_skills_screen.dart';
import 'package:roboscout_iq/src/ui/screens/team_events_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String eventsList = '/events';
  static const String eventDetail = '/event_detail';
  static const String teamDetail = '/team_detail';
  static const String teamEvents = '/team_events';
  static const String matchDetail = '/match_detail';
  static const String scoutingForm = '/scouting_form';
  static const String exports = '/exports';
  static const String settings = '/settings';
  static const String worldSkills = '/world_skills';
  static const String favorites = '/favorites';
  static const String resources = '/resources';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (_) => const SplashScreen());
      case eventsList:
        return CupertinoPageRoute(builder: (_) => const EventsListScreen());
      case eventDetail:
        final event = routeSettings.arguments as Event?; // TODO: Handle null/id
        return CupertinoPageRoute(
            builder: (_) => EventDetailScreen(event: event!));
      case teamDetail:
        final team = routeSettings.arguments as Team?;
        // This was the old viewer, we use teamEvents now or keep for compatibility?
        // Let's use teamEvents for the requested feature.
        return CupertinoPageRoute(
            builder: (_) => TeamEventsScreen(team: team!));
      case teamEvents:
        final team = routeSettings.arguments as Team?;
        return CupertinoPageRoute(
            builder: (_) => TeamEventsScreen(team: team!));
      case matchDetail:
        final match = routeSettings.arguments as MatchModel?;
        return CupertinoPageRoute(
            builder: (_) => MatchDetailScreen(match: match!));
      case scoutingForm:
        // Pass arguments like eventId, matchId, teamId, or an existing entry
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return CupertinoPageRoute(
            builder: (_) => ScoutingFormScreen(args: args));
      case exports:
        return CupertinoPageRoute(builder: (_) => const ExportsScreen());
      case settings:
        return CupertinoPageRoute(builder: (_) => const SettingsScreen());
      case worldSkills:
        return CupertinoPageRoute(builder: (_) => const WorldSkillsScreen());
      case resources:
        return CupertinoPageRoute(builder: (_) => const ResourcesScreen());
      // Favorites will be part of the main tab view, but adding route just in case
      case favorites:
        return CupertinoPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Favorites'))));
      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child:
                          Text('No route defined for ${routeSettings.name}')),
                ));
    }
  }
}
