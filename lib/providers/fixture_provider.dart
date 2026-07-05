import 'package:flutter/material.dart';

import '../models/fixture_model.dart';
import '../services/api_service.dart';

class FixtureProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;

  List<FixtureModel> todayFixtures = [];
  List<FixtureModel> liveFixtures = [];

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
}