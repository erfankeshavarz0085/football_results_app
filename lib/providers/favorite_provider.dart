import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/league_model.dart';
import '../models/team_model.dart';

class FavoriteTeamModel {
  final int id;
  final String name;
  final String logo;
  final String country;

  FavoriteTeamModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.country,
  });

  factory FavoriteTeamModel.fromTeam(TeamModel team) {
    return FavoriteTeamModel(
      id: team.id,
      name: team.name,
      logo: team.logo,
      country: team.country,
    );
  }

  factory FavoriteTeamModel.fromJson(Map<String, dynamic> json) {
    return FavoriteTeamModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'country': country,
    };
  }
}

class FavoriteProvider extends ChangeNotifier {
  static const String _teamsKey = 'favorite_teams';
  static const String _leaguesKey = 'favorite_leagues';

  final List<FavoriteTeamModel> _favoriteTeams = [];
  final List<LeagueModel> _favoriteLeagues = [];
  bool _isLoaded = false;

  List<FavoriteTeamModel> get favoriteTeams => List.unmodifiable(_favoriteTeams);
  List<LeagueModel> get favoriteLeagues => List.unmodifiable(_favoriteLeagues);
  bool get isLoaded => _isLoaded;

  FavoriteProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTeams = prefs.getStringList(_teamsKey) ?? [];
    final leagueIds = prefs.getStringList(_leaguesKey) ?? [];

    _favoriteTeams
      ..clear()
      ..addAll(
        rawTeams
            .map(_decodeFavoriteTeam)
            .whereType<FavoriteTeamModel>(),
      );

    _favoriteLeagues
      ..clear()
      ..addAll(
        leagueIds
            .map(int.tryParse)
            .whereType<int>()
            .map((id) => LeagueCatalog.byId(id, 'League $id')),
      );

    _isLoaded = true;
    notifyListeners();
  }

  FavoriteTeamModel? _decodeFavoriteTeam(String rawTeam) {
    try {
      return FavoriteTeamModel.fromJson(
        jsonDecode(rawTeam) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  bool isFavorite(int teamId) {
    return _favoriteTeams.any((team) => team.id == teamId);
  }

  bool isFavoriteLeague(int leagueId) {
    return _favoriteLeagues.any((league) => league.id == leagueId);
  }

  Future<void> toggleFavoriteTeam(FavoriteTeamModel team) async {
    if (isFavorite(team.id)) {
      _favoriteTeams.removeWhere((favoriteTeam) => favoriteTeam.id == team.id);
    } else {
      _favoriteTeams.add(team);
    }

    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavoriteTeam(int teamId) async {
    _favoriteTeams.removeWhere((team) => team.id == teamId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleFavoriteLeague(LeagueModel league) async {
    if (isFavoriteLeague(league.id)) {
      _favoriteLeagues.removeWhere((favoriteLeague) {
        return favoriteLeague.id == league.id;
      });
    } else {
      _favoriteLeagues.add(league);
    }

    await _saveFavoriteLeagues();
    notifyListeners();
  }

  Future<void> removeFavoriteLeague(int leagueId) async {
    _favoriteLeagues.removeWhere((league) => league.id == leagueId);
    await _saveFavoriteLeagues();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final rawTeams = _favoriteTeams.map((team) {
      return jsonEncode(team.toJson());
    }).toList();

    await prefs.setStringList(_teamsKey, rawTeams);
  }

  Future<void> _saveFavoriteLeagues() async {
    final prefs = await SharedPreferences.getInstance();

    final leagueIds = _favoriteLeagues.map((league) {
      return league.id.toString();
    }).toList();

    await prefs.setStringList(_leaguesKey, leagueIds);
  }
}
