import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  /// API-Football identifies a cross-year season by its starting year.
  /// July is used as the rollover so the app advances automatically each year.
  static int get currentSeason {
    final configured = int.tryParse(dotenv.env['API_DEFAULT_SEASON'] ?? '');
    if (configured != null) return configured;

    final now = DateTime.now();
    return now.month >= DateTime.july ? now.year : now.year - 1;
  }

  static String get currentSeasonLabel {
    final season = currentSeason;
    return '$season/${season + 1}';
  }

  static String get apiKey {
    return dotenv.env['API_KEY'] ?? '';
  }

  static bool get apiEnabled {
    return (dotenv.env['API_ENABLED'] ?? 'true').toLowerCase() == 'true';
  }

  static bool get demoFallbackEnabled {
    return (dotenv.env['API_DEMO_FALLBACK_ENABLED'] ?? 'false').toLowerCase() ==
        'true';
  }

  static int get apiRequestIntervalMs {
    return int.tryParse(dotenv.env['API_REQUEST_INTERVAL_MS'] ?? '') ?? 250;
  }

  static String get demoFixtureDate {
    return dotenv.env['API_DEMO_FIXTURE_DATE'] ?? '';
  }

  static const String baseUrl = 'https://v3.football.api-sports.io';

  static const int premierLeague = 39;
  static const int laLiga = 140;
  static const int serieA = 135;
  static const int bundesliga = 78;
  static const int ligue1 = 61;
  static const int championsLeague = 2;
}
