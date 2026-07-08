import 'package:flutter/material.dart';

import '../models/team_model.dart';
import '../services/api_service.dart';

class TeamProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;
  TeamDetailsModel? teamDetails;

  bool isSearchLoading = false;
  String? searchErrorMessage;
  List<TeamModel> searchResults = [];

  Future<void> loadTeamDetails(int teamId) async {
    isLoading = true;
    errorMessage = null;
    teamDetails = null;
    notifyListeners();

    try {
      teamDetails = await _apiService.getTeamDetails(teamId);
    } catch (e) {
      errorMessage = e.toString();
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
      searchErrorMessage = e.toString();
    }

    isSearchLoading = false;
    notifyListeners();
  }
}
