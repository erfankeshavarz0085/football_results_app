import 'package:flutter/material.dart';

import '../models/fixture_model.dart';
import '../models/standing_model.dart';
import '../services/api_service.dart';

class FixtureProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;

  bool isStandingsLoading = false;
  String? standingsErrorMessage;

  List<FixtureModel> todayFixtures = [];
  List<FixtureModel> liveFixtures = [];

  final Map<int, List<StandingModel>> standingsByLeague = {};

  Future<void> loadTodayFixtures() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      todayFixtures = await _apiService.getTodayFixtures();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadLiveFixtures() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      liveFixtures = await _apiService.getLiveFixtures();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadLeagueStandings(
    int leagueId, {
    int season = 2024,
  }) async {
    isStandingsLoading = true;
    standingsErrorMessage = null;
    notifyListeners();

    try {
      final standings = await _apiService.getLeagueStandings(
        leagueId,
        season: season,
      );
      standingsByLeague[_standingsKey(leagueId, season)] = standings;
    } catch (e) {
      standingsErrorMessage = e.toString();
    }

    isStandingsLoading = false;
    notifyListeners();
  }

  List<StandingModel> getStandingsForLeague(
    int leagueId, {
    int season = 2024,
  }) {
    return standingsByLeague[_standingsKey(leagueId, season)] ?? [];
  }

  int _standingsKey(int leagueId, int season) {
    return leagueId * 10000 + season;
  }
}
