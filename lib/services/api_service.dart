import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/fixture_model.dart';
import '../models/standing_model.dart';
import '../models/team_model.dart';
import '../utils/constants.dart';
import '../models/match_detail_model.dart';

class ApiService {
  static final Map<String, _CacheItem<List<FixtureModel>>> _fixtureCache = {};
  static final Map<String, _CacheItem<List<StandingModel>>> _standingsCache = {};

  Map<String, String> get _headers => {
        'x-apisports-key': AppConstants.apiKey,
      };

  Future<List<FixtureModel>> getTodayFixtures() async {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?date=$date&timezone=Asia/Tehran',
    );

    return _fetchFixturesWithCache(
      cacheKey: 'today_$date',
      url: url,
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<List<FixtureModel>> getLiveFixtures() async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?live=all&timezone=Asia/Tehran',
    );

    return _fetchFixturesWithCache(
      cacheKey: 'live_fixtures',
      url: url,
      cacheDuration: const Duration(seconds: 30),
    );
  }

  Future<List<FixtureModel>> getLeagueFixtures(int leagueId) async {
    const season = 2024;

    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?league=$leagueId&season=$season&timezone=Asia/Tehran',
    );

    return _fetchFixturesWithCache(
      cacheKey: 'league_${leagueId}_season_$season',
      url: url,
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<List<StandingModel>> getLeagueStandings(int leagueId) async {
    const season = 2024;

    final url = Uri.parse(
      '${AppConstants.baseUrl}/standings?league=$leagueId&season=$season',
    );

    return _fetchStandingsWithCache(
      cacheKey: 'standings_${leagueId}_season_$season',
      url: url,
      cacheDuration: const Duration(hours: 1),
    );
  }

  Future<List<FixtureModel>> getWorldCupFixtures() async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?league=1&season=2026&timezone=Asia/Tehran',
    );

    return _fetchFixturesWithCache(
      cacheKey: 'world_cup_2026',
      url: url,
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<List<FixtureModel>> _fetchFixturesWithCache({
    required String cacheKey,
    required Uri url,
    required Duration cacheDuration,
  }) async {
    final cached = _fixtureCache[cacheKey];

    if (cached != null && !cached.isExpired(cacheDuration)) {
      debugPrint('CACHE HIT: $cacheKey');
      return cached.data;
    }

    debugPrint('CACHE MISS: $cacheKey');

    final data = await _fetchFixtures(url);
    _fixtureCache[cacheKey] = _CacheItem(data: data);

    return data;
  }

  Future<List<StandingModel>> _fetchStandingsWithCache({
    required String cacheKey,
    required Uri url,
    required Duration cacheDuration,
  }) async {
    final cached = _standingsCache[cacheKey];

    if (cached != null && !cached.isExpired(cacheDuration)) {
      debugPrint('CACHE HIT: $cacheKey');
      return cached.data;
    }

    debugPrint('CACHE MISS: $cacheKey');

    final data = await _fetchStandings(url);
    _standingsCache[cacheKey] = _CacheItem(data: data);

    return data;
  }

  Future<List<FixtureModel>> _fetchFixtures(Uri url) async {
    try {
      debugPrint('API URL: $url');

      final response = await _getWithRetry(url);

      debugPrint('STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].toString() != '{}') {
          debugPrint('API ERRORS: ${data['errors']}');
        }

        final List fixtures = data['response'] ?? [];

        return fixtures.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API EXCEPTION: $e');
      throw Exception('خطا در دریافت اطلاعات: $e');
    }
  }

  Future<List<StandingModel>> _fetchStandings(Uri url) async {
    try {
      debugPrint('API URL: $url');

      final response = await _getWithRetry(url);

      debugPrint('STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null && data['errors'].toString() != '{}') {
          debugPrint('API ERRORS: ${data['errors']}');
        }

        final List responseList = data['response'] ?? [];

        if (responseList.isEmpty) {
          return [];
        }

        final standingsData = responseList[0]['league']?['standings'];

        if (standingsData == null || standingsData.isEmpty) {
          return [];
        }

        final List firstTable = standingsData[0] ?? [];

        return firstTable.map((json) => StandingModel.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API EXCEPTION: $e');
      throw Exception('خطا در دریافت جدول: $e');
    }
  }
  Future<MatchDetailModel?> getMatchDetails(int fixtureId) async {
    final fixtureUrl = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?id=$fixtureId',
    );

    final eventsUrl = Uri.parse(
      '${AppConstants.baseUrl}/fixtures/events?fixture=$fixtureId',
    );

    final statisticsUrl = Uri.parse(
      '${AppConstants.baseUrl}/fixtures/statistics?fixture=$fixtureId',
    );

    final lineupsUrl = Uri.parse(
      '${AppConstants.baseUrl}/fixtures/lineups?fixture=$fixtureId',
    );

    try {
      final fixtureList = await _fetchResponseList(fixtureUrl);

      if (fixtureList.isEmpty) {
        return null;
      }

      final detailResults = await Future.wait([
        _fetchOptionalResponseList(eventsUrl, 'events'),
        _fetchOptionalResponseList(statisticsUrl, 'statistics'),
        _fetchOptionalResponseList(lineupsUrl, 'lineups'),
      ]);

      final events = detailResults[0]
          .map((json) => MatchEventModel.fromJson(json))
          .toList();

      final statistics = detailResults[1]
          .map((json) => MatchStatisticModel.fromJson(json))
          .toList();

      final lineups = detailResults[2]
          .map((json) => MatchLineupModel.fromJson(json))
          .toList();

      return MatchDetailModel.fromJson(
        fixtureList[0],
        events: events,
        statistics: statistics,
        lineups: lineups,
      );
    } catch (e) {
      debugPrint('MATCH DETAIL ERROR: $e');
      throw Exception(
        'خطا در دریافت جزئیات بازی: $e',
      );
    }
  }

  Future<TeamDetailsModel?> getTeamDetails(int teamId) async {
    const season = 2024;

    final teamUrl = Uri.parse(
      '${AppConstants.baseUrl}/teams?id=$teamId',
    );

    final fixturesUrl = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?team=$teamId&season=$season&last=5&timezone=Asia/Tehran',
    );

    try {
      final teamResponse = await _fetchResponseList(teamUrl);

      if (teamResponse.isEmpty) {
        return null;
      }

      final fixturesResponse = await _fetchOptionalResponseList(
        fixturesUrl,
        'team fixtures',
      );

      final recentFixtures = fixturesResponse
          .map((json) => FixtureModel.fromJson(json))
          .toList();

      return TeamDetailsModel(
        team: TeamModel.fromJson(teamResponse[0]),
        recentFixtures: recentFixtures,
      );
    } catch (e) {
      debugPrint('TEAM DETAILS ERROR: $e');
      throw Exception('خطا در دریافت اطلاعات تیم: $e');
    }
  }

  Future<List<dynamic>> _fetchResponseList(Uri url) async {
    debugPrint('API URL: $url');

    final response = await _getWithRetry(url);

    debugPrint('STATUS: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['errors'] != null && data['errors'].toString() != '{}') {
      debugPrint('API ERRORS: ${data['errors']}');
    }

    return data['response'] ?? [];
  }

  Future<List<dynamic>> _fetchOptionalResponseList(
    Uri url,
    String label,
  ) async {
    try {
      return await _fetchResponseList(url);
    } catch (e) {
      debugPrint('OPTIONAL MATCH DETAIL $label ERROR: $e');
      return [];
    }
  }

  Future<http.Response> _getWithRetry(Uri url) async {
    const maxAttempts = 3;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await http
            .get(url, headers: _headers)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        if (attempt == maxAttempts) {
          rethrow;
        }

        debugPrint('API RETRY $attempt/$maxAttempts: $e');
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    throw Exception('API request failed');
  }
}

class _CacheItem<T> {
  final T data;
  final DateTime createdAt;

  _CacheItem({
    required this.data,
  }) : createdAt = DateTime.now();

  bool isExpired(Duration duration) {
    return DateTime.now().difference(createdAt) > duration;
  }
}
