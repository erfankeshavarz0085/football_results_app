import 'package:flutter/material.dart';

import '../models/team_model.dart';
import '../services/api_service.dart';

class TeamProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;
  TeamDetailsModel? teamDetails;

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
}
