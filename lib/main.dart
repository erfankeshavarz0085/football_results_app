import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorite_provider.dart';
import 'providers/fixture_provider.dart';
import 'providers/league_provider.dart';

import 'screens/splash_screen.dart';

import 'utils/app_theme.dart';

void main() {
  runApp(const FootballApp());
}

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FixtureProvider()),
        ChangeNotifierProvider(create: (_) => LeagueProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
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