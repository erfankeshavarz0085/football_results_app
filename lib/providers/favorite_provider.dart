import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fixture_model.dart';
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
  static const String _matchesKey = 'followed_matches';

  final List<FavoriteTeamModel> _favoriteTeams = [];
  final List<LeagueModel> _favoriteLeagues = [];
  final List<FollowedMatchModel> _followedMatches = [];
  bool _isLoaded = false;

  List<FavoriteTeamModel> get favoriteTeams => List.unmodifiable(_favoriteTeams);
  List<LeagueModel> get favoriteLeagues => List.unmodifiable(_favoriteLeagues);
  List<FollowedMatchModel> get followedMatches {
    return List.unmodifiable(_followedMatches);
  }

  bool get isLoaded => _isLoaded;

  FavoriteProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTeams = prefs.getStringList(_teamsKey) ?? [];
    final leagueIds = prefs.getStringList(_leaguesKey) ?? [];
    final rawMatches = prefs.getStringList(_matchesKey) ?? [];

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

    _followedMatches
      ..clear()
      ..addAll(
        rawMatches
            .map(_decodeFollowedMatch)
            .whereType<FollowedMatchModel>(),
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

  bool isFollowedMatch(int fixtureId) {
    return _followedMatches.any((match) => match.fixtureId == fixtureId);
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

  Future<void> toggleFollowedMatch(FixtureModel fixture) async {
    if (isFollowedMatch(fixture.id)) {
      _followedMatches.removeWhere((match) => match.fixtureId == fixture.id);
    } else {
      _followedMatches.insert(0, FollowedMatchModel.fromFixture(fixture));
    }

    await _saveFollowedMatches();
    notifyListeners();
  }

  Future<void> removeFollowedMatch(int fixtureId) async {
    _followedMatches.removeWhere((match) => match.fixtureId == fixtureId);
    await _saveFollowedMatches();
    notifyListeners();
  }

  Future<void> updateMatchAlert({
    required int fixtureId,
    bool? kickoffAlert,
    bool? goalAlert,
    bool? fullTimeAlert,
  }) async {
    final index = _followedMatches.indexWhere((match) {
      return match.fixtureId == fixtureId;
    });

    if (index == -1) {
      return;
    }

    _followedMatches[index] = _followedMatches[index].copyWith(
      kickoffAlert: kickoffAlert,
      goalAlert: goalAlert,
      fullTimeAlert: fullTimeAlert,
    );

    await _saveFollowedMatches();
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

  Future<void> _saveFollowedMatches() async {
    final prefs = await SharedPreferences.getInstance();

    final rawMatches = _followedMatches.map((match) {
      return jsonEncode(match.toJson());
    }).toList();

    await prefs.setStringList(_matchesKey, rawMatches);
  }

  FollowedMatchModel? _decodeFollowedMatch(String rawMatch) {
    try {
      return FollowedMatchModel.fromJson(
        jsonDecode(rawMatch) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

class FollowedMatchModel {
  final int fixtureId;
  final int leagueId;
  final String leagueName;
  final String leagueLogo;
  final String country;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final String date;
  final bool kickoffAlert;
  final bool goalAlert;
  final bool fullTimeAlert;

  FollowedMatchModel({
    required this.fixtureId,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    required this.country,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.date,
    this.kickoffAlert = true,
    this.goalAlert = true,
    this.fullTimeAlert = true,
  });

  factory FollowedMatchModel.fromFixture(FixtureModel fixture) {
    return FollowedMatchModel(
      fixtureId: fixture.id,
      leagueId: fixture.leagueId,
      leagueName: fixture.leagueName,
      leagueLogo: fixture.leagueLogo,
      country: fixture.country,
      homeTeam: fixture.homeTeam,
      awayTeam: fixture.awayTeam,
      homeLogo: fixture.homeLogo,
      awayLogo: fixture.awayLogo,
      homeScore: fixture.homeScore,
      awayScore: fixture.awayScore,
      status: fixture.status,
      date: fixture.date,
    );
  }

  FollowedMatchModel copyWith({
    bool? kickoffAlert,
    bool? goalAlert,
    bool? fullTimeAlert,
  }) {
    return FollowedMatchModel(
      fixtureId: fixtureId,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      country: country,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeLogo: homeLogo,
      awayLogo: awayLogo,
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      date: date,
      kickoffAlert: kickoffAlert ?? this.kickoffAlert,
      goalAlert: goalAlert ?? this.goalAlert,
      fullTimeAlert: fullTimeAlert ?? this.fullTimeAlert,
    );
  }

  factory FollowedMatchModel.fromJson(Map<String, dynamic> json) {
    return FollowedMatchModel(
      fixtureId: json['fixtureId'] ?? 0,
      leagueId: json['leagueId'] ?? 0,
      leagueName: json['leagueName'] ?? '',
      leagueLogo: json['leagueLogo'] ?? '',
      country: json['country'] ?? '',
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      homeLogo: json['homeLogo'] ?? '',
      awayLogo: json['awayLogo'] ?? '',
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      kickoffAlert: json['kickoffAlert'] ?? true,
      goalAlert: json['goalAlert'] ?? true,
      fullTimeAlert: json['fullTimeAlert'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fixtureId': fixtureId,
      'leagueId': leagueId,
      'leagueName': leagueName,
      'leagueLogo': leagueLogo,
      'country': country,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeLogo,
      'awayLogo': awayLogo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': status,
      'date': date,
      'kickoffAlert': kickoffAlert,
      'goalAlert': goalAlert,
      'fullTimeAlert': fullTimeAlert,
    };
  }
}
