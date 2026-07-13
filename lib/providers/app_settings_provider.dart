import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _showFavoritesHomeKey = 'show_favorites_home';
  static const String _showRecentSearchKey = 'show_recent_search';
  static const String _showMatchAlertsKey = 'show_match_alerts';
  static const String _demoFallbackKey = 'demo_fallback_enabled';

  final SharedPreferences _preferences;

  bool showFavoritesOnHome = true;
  bool showRecentlyViewedInSearch = true;
  bool showMatchAlertControls = true;
  bool demoFallbackEnabled = false;
  bool isLoaded = false;

  AppSettingsProvider(this._preferences) {
    loadSettings();
  }

  void loadSettings() {
    showFavoritesOnHome = _preferences.getBool(_showFavoritesHomeKey) ?? true;
    showRecentlyViewedInSearch =
        _preferences.getBool(_showRecentSearchKey) ?? true;
    showMatchAlertControls = _preferences.getBool(_showMatchAlertsKey) ?? true;
    demoFallbackEnabled = _preferences.getBool(_demoFallbackKey) ?? false;
    isLoaded = true;

    notifyListeners();
  }

  Future<void> setShowFavoritesOnHome(bool value) async {
    showFavoritesOnHome = value;
    notifyListeners();

    await _preferences.setBool(_showFavoritesHomeKey, value);
  }

  Future<void> setShowRecentlyViewedInSearch(bool value) async {
    showRecentlyViewedInSearch = value;
    notifyListeners();

    await _preferences.setBool(_showRecentSearchKey, value);
  }

  Future<void> setShowMatchAlertControls(bool value) async {
    showMatchAlertControls = value;
    notifyListeners();

    await _preferences.setBool(_showMatchAlertsKey, value);
  }

  Future<void> setDemoFallbackEnabled(bool value) async {
    demoFallbackEnabled = value;
    notifyListeners();

    await _preferences.setBool(_demoFallbackKey, value);
  }
}
