import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primaryColor = Color(0xFF49CAEB);
  static const Color _darkBackground = Colors.black;

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: '.SF Pro Text',
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
    ),
    // Add other overrides as needed...
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    fontFamily: '.SF Pro Text',
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: _darkBackground,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: _darkBackground,
    ),
    // Add other overrides as needed...
  );

  /// Custom Cupertino theme logic that respects Material theme brightness.
  /// Used by default via `MaterialBasedCupertinoThemeData` in `app.dart`.
  static CupertinoThemeData cupertinoTheme(BuildContext context) {
    return MaterialBasedCupertinoThemeData(materialTheme: Theme.of(context));
  }
}
