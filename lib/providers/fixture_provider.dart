import 'package:flutter/material.dart';

class FixtureProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTodayFixtures() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();
  }
}