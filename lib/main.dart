import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/favorite_provider.dart';
import 'providers/fixture_provider.dart';
import 'providers/match_detail_provider.dart';
import 'providers/recent_view_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/team_provider.dart';

import 'screens/splash_screen.dart';

import 'utils/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final preferences = await SharedPreferences.getInstance();
  runApp(FootballApp(preferences: preferences));
}


class FootballApp extends StatelessWidget {

  final SharedPreferences preferences;

  const FootballApp({
    super.key,
    required this.preferences,
  });


  @override
  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [

        ChangeNotifierProvider(
          create: (_) => FixtureProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(preferences),
        ),


        ChangeNotifierProvider(
          create: (_) => MatchDetailProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => TeamProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => RecentViewProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider(preferences),
        ),

      ],


      child: MaterialApp(

        debugShowCheckedModeBanner: false,

        title: "Football Results",


        theme: AppTheme.darkTheme,


        home: const SplashScreen(),

      ),

    );

  }

}
