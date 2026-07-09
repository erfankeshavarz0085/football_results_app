import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _showFavoritesHomeKey = 'show_favorites_home';
  static const String _showRecentSearchKey = 'show_recent_search';
  static const String _showMatchAlertsKey = 'show_match_alerts';

  bool showFavoritesOnHome = true;
  bool showRecentlyViewedInSearch = true;
  bool showMatchAlertControls = true;
  bool isLoaded = false;

  AppSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    showFavoritesOnHome = prefs.getBool(_showFavoritesHomeKey) ?? true;
    showRecentlyViewedInSearch = prefs.getBool(_showRecentSearchKey) ?? true;
    showMatchAlertControls = prefs.getBool(_showMatchAlertsKey) ?? true;
    isLoaded = true;

    notifyListeners();
  }

  Future<void> setShowFavoritesOnHome(bool value) async {
    showFavoritesOnHome = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showFavoritesHomeKey, value);
  }

  Future<void> setShowRecentlyViewedInSearch(bool value) async {
    showRecentlyViewedInSearch = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showRecentSearchKey, value);
  }

  Future<void> setShowMatchAlertControls(bool value) async {
    showMatchAlertControls = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showMatchAlertsKey, value);
  }
}
