# RoboScout IQ

An offline-first VEX IQ scouting app built with Flutter.

## Overview
RoboScout IQ is designed for VEX IQ competition scouting. It allows users to fetch event data from RobotEvents, scout matches offline, and export data for analysis. The app is built with a "Privacy First" and "No Backend" approach—all data lives on your device.

## Features
- **Offline First**: All data is stored locally using Hive.
- **RobotEvents Integration**: Fetch events, teams, and matches directly from the official API.
- **Scouting**: Scout matches with a custom form (Auto/Driver points).
- **Match Prediction**: Deterministic win probability estimation using Elo.
- **Exports**: Share scouting data via CSV.
- **No ML**: Purely algorithmic predictions.

## Setup

### Prerequisites
- Flutter SDK (>=3.0.0 recommended, code compatible with 2.18+)
- Dart SDK

### Installation
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate data models (Freezed/Hive adapters).

### API Key
To use the RobotEvents integration, you need an API key.
1. Go to [RobotEvents.com](https://www.robotevents.com/api/v2) and generate a personal access token.
2. Open the app, go to **Settings**.
3. Enter your API Key and save.

## Building
- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`

## Testing
Run unit and widget tests:
```bash
flutter test
```

## Architecture
- **State Management**: Riverpod
- **Local DB**: Hive
- **HTTP**: Dio
- **Navigation**: Named Routes

## Privacy
This app does not collect any personal data. All scouting data is stored locally on your device.

## Contributors
- Implemented by Antigravity (Google DeepMind)
