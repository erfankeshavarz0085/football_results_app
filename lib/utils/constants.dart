import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConstants {


  static String get apiKey {

    return dotenv.env['API_KEY'] ?? '';

  }



  static const String baseUrl =
      "https://v3.football.api-sports.io";



  // لیگ‌ها

  static const int premierLeague = 39;

  static const int laLiga = 140;

  static const int serieA = 135;

  static const int bundesliga = 78;

  static const int ligue1 = 61;

  static const int championsLeague = 2;



}