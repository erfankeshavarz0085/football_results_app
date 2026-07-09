import 'package:flutter/material.dart';

import '../models/match_detail_model.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

class MatchDetailProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;
  MatchDetailModel? matchDetail;

  Future<void> loadMatchDetails(int fixtureId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      matchDetail = await _apiService.getMatchDetails(fixtureId);
    } catch (e) {
      errorMessage = ErrorMessages.fromException(e);
    }

    isLoading = false;
    notifyListeners();
  }
}
