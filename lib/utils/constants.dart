import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiKey {
    return dotenv.env['API_KEY'] ?? '';
  }

  static bool get apiEnabled {
    return (dotenv.env['API_ENABLED'] ?? 'true').toLowerCase() == 'true';
  }

  static bool get demoFallbackEnabled {
    return (dotenv.env['API_DEMO_FALLBACK_ENABLED'] ?? 'true').toLowerCase() ==
        'true';
  }

  static int get apiRequestIntervalMs {
    return int.tryParse(dotenv.env['API_REQUEST_INTERVAL_MS'] ?? '') ?? 1200;
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
