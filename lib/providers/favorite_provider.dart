import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<int> _favoriteTeams = [];

  List<int> get favoriteTeams => _favoriteTeams;

  bool isFavorite(int teamId) {
    return _favoriteTeams.contains(teamId);
  }

  void toggleFavorite(int teamId) {
    if (_favoriteTeams.contains(teamId)) {
      _favoriteTeams.remove(teamId);
    } else {
      _favoriteTeams.add(teamId);
    }
    notifyListeners();
  }
}