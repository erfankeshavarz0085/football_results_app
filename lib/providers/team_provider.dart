import 'package:flutter/material.dart';

import '../models/league_model.dart';
import '../models/team_model.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

class TeamProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;
  TeamDetailsModel? teamDetails;

  bool isSearchLoading = false;
  String? searchErrorMessage;
  List<TeamModel> searchResults = [];

  bool isLeagueSearchLoading = false;
  String? leagueSearchErrorMessage;
  List<LeagueModel> leagueSearchResults = [];

  Future<void> loadTeamDetails(int teamId) async {
    isLoading = true;
    errorMessage = null;
    teamDetails = null;
    notifyListeners();

    try {
      teamDetails = await _apiService.getTeamDetails(teamId);
    } catch (e) {
      errorMessage = ErrorMessages.fromException(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchTeams(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      searchResults = [];
      searchErrorMessage = null;
      isSearchLoading = false;
      notifyListeners();
      return;
    }

    isSearchLoading = true;
    searchErrorMessage = null;
    notifyListeners();

    try {
      searchResults = await _apiService.searchTeams(trimmedQuery);
    } catch (e) {
      searchErrorMessage = ErrorMessages.fromException(e);
    }

    isSearchLoading = false;
    notifyListeners();
  }

  Future<void> searchLeagues(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      leagueSearchResults = [];
      leagueSearchErrorMessage = null;
      isLeagueSearchLoading = false;
      notifyListeners();
      return;
    }

    isLeagueSearchLoading = true;
    leagueSearchErrorMessage = null;
    notifyListeners();

    try {
      leagueSearchResults = await _apiService.searchLeagues(trimmedQuery);
    } catch (e) {
      leagueSearchErrorMessage = ErrorMessages.fromException(e);
    }

    isLeagueSearchLoading = false;
    notifyListeners();
  }
}
