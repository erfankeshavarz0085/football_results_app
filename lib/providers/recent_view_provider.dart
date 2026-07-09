import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fixture_model.dart';
import '../models/league_model.dart';
import '../models/team_model.dart';

enum RecentViewType {
  match,
  team,
  league,
}

class RecentViewItem {
  final RecentViewType type;
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int? season;
  final DateTime viewedAt;

  const RecentViewItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.viewedAt,
    this.season,
  });

  factory RecentViewItem.match(FixtureModel fixture) {
    return RecentViewItem(
      type: RecentViewType.match,
      id: fixture.id,
      title: '${fixture.homeTeam} vs ${fixture.awayTeam}',
      subtitle: fixture.leagueName,
      imageUrl: fixture.leagueLogo,
      viewedAt: DateTime.now(),
      season: fixture.season,
    );
  }

  factory RecentViewItem.team({
    required int id,
    required String name,
    required String logo,
    required String country,
  }) {
    return RecentViewItem(
      type: RecentViewType.team,
      id: id,
      title: name,
      subtitle: country.isEmpty ? 'Team' : country,
      imageUrl: logo,
      viewedAt: DateTime.now(),
    );
  }

  factory RecentViewItem.league(LeagueModel league) {
    return RecentViewItem(
      type: RecentViewType.league,
      id: league.id,
      title: league.name,
      subtitle: league.country,
      imageUrl: league.logoUrl,
      viewedAt: DateTime.now(),
      season: league.apiSeason,
    );
  }

  factory RecentViewItem.fromJson(Map<String, dynamic> json) {
    final season = json['season'];

    return RecentViewItem(
      type: RecentViewType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => RecentViewType.match,
      ),
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      season: season is int ? season : null,
      viewedAt: DateTime.tryParse(json['viewedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'season': season,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }
}

class RecentViewProvider extends ChangeNotifier {
  static const String _recentViewsKey = 'recent_views';
  static const int _maxItems = 12;

  final List<RecentViewItem> _items = [];
  bool _isLoaded = false;

  List<RecentViewItem> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;

  RecentViewProvider() {
    loadRecentViews();
  }

  Future<void> loadRecentViews() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_recentViewsKey) ?? [];

    _items
      ..clear()
      ..addAll(
        rawItems.map(_decodeItem).whereType<RecentViewItem>(),
      );

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addMatch(FixtureModel fixture) async {
    await _addItem(RecentViewItem.match(fixture));
  }

  Future<void> addTeam({
    required int id,
    required String name,
    required String logo,
    required String country,
  }) async {
    await _addItem(
      RecentViewItem.team(
        id: id,
        name: name,
        logo: logo,
        country: country,
      ),
    );
  }

  Future<void> addTeamModel(TeamModel team) async {
    await addTeam(
      id: team.id,
      name: team.name,
      logo: team.logo,
      country: team.country,
    );
  }

  Future<void> addLeague(LeagueModel league) async {
    await _addItem(RecentViewItem.league(league));
  }

  Future<void> clear() async {
    _items.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentViewsKey);

    notifyListeners();
  }

  Future<void> _addItem(RecentViewItem item) async {
    if (item.id == 0 || item.title.isEmpty) {
      return;
    }

    _items.removeWhere((existing) {
      return existing.type == item.type && existing.id == item.id;
    });

    _items.insert(0, item);

    if (_items.length > _maxItems) {
      _items.removeRange(_maxItems, _items.length);
    }

    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = _items.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await prefs.setStringList(_recentViewsKey, rawItems);
  }

  RecentViewItem? _decodeItem(String rawItem) {
    try {
      return RecentViewItem.fromJson(
        jsonDecode(rawItem) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
