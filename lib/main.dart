import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/favorite_provider.dart';
import 'providers/fixture_provider.dart';
import 'providers/league_provider.dart';
import 'providers/match_detail_provider.dart';

import 'screens/splash_screen.dart';

import 'utils/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const FootballApp());
}


class FootballApp extends StatelessWidget {

  const FootballApp({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [

        ChangeNotifierProvider(
          create: (_) => FixtureProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => LeagueProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => MatchDetailProvider(),
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
