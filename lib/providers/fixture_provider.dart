import 'package:flutter/material.dart';

import '../models/fixture_model.dart';
import '../models/standing_model.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';
import '../utils/constants.dart';

class FixtureProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;

  bool isStandingsLoading = false;
  String? standingsErrorMessage;

  DateTime selectedDate = DateTime.now();
  List<FixtureModel> todayFixtures = [];
  List<FixtureModel> liveFixtures = [];

  final Map<int, List<StandingModel>> standingsByLeague = {};

  bool get isUsingDemoFixtures {
    return todayFixtures.any((fixture) => fixture.id < 0);
  }

  bool get isUsingDemoLiveFixtures {
    return liveFixtures.any((fixture) => fixture.id < 0);
  }

  Future<void> loadTodayFixtures() async {
    selectedDate = DateTime.now();
    await loadFixturesForDate(selectedDate);
  }

  Future<void> loadFixturesForDate(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      todayFixtures = await _apiService.getFixturesByDate(selectedDate);
    } catch (e) {
      errorMessage = ErrorMessages.fromException(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadPreviousDay() {
    return loadFixturesForDate(selectedDate.subtract(const Duration(days: 1)));
  }

  Future<void> loadNextDay() {
    return loadFixturesForDate(selectedDate.add(const Duration(days: 1)));
  }

  Future<void> refreshSelectedDate() {
    return loadFixturesForDate(selectedDate);
  }

  bool get isSelectedDateToday {
    final now = DateTime.now();

    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  Future<void> loadLiveFixtures() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      liveFixtures = await _apiService.getLiveFixtures();
    } catch (e) {
      errorMessage = ErrorMessages.fromException(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadLeagueStandings(
    int leagueId, {
    int? season,
  }) async {
    season ??= AppConstants.currentSeason;
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
      standingsErrorMessage = ErrorMessages.fromException(e);
    }

    isStandingsLoading = false;
    notifyListeners();
  }

  List<StandingModel> getStandingsForLeague(
    int leagueId, {
    int? season,
  }) {
    season ??= AppConstants.currentSeason;
    return standingsByLeague[_standingsKey(leagueId, season)] ?? [];
  }

  int _standingsKey(int leagueId, int season) {
    return leagueId * 10000 + season;
  }
}
