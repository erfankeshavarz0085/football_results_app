import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fixture_model.dart';
import '../models/league_model.dart';
import '../models/standing_model.dart';
import '../models/team_model.dart';
import '../utils/constants.dart';
import '../utils/demo_football_data.dart';
import '../models/match_detail_model.dart';

class ApiService {
  static const String _persistentCachePrefix = 'api_cache';

  static final Map<String, _CacheItem<List<FixtureModel>>> _fixtureCache = {};
  static final Map<String, _CacheItem<List<StandingModel>>> _standingsCache = {};
  static final Map<String, _CacheItem<List<TeamModel>>> _teamSearchCache = {};
  static final Map<String, _CacheItem<List<LeagueModel>>> _leagueSearchCache =
      {};
  static final Map<String, Future<http.Response>> _inFlightRequests = {};
  static DateTime? _lastRequestAt;
  static Future<void> _requestQueue = Future.value();

  Map<String, String> get _headers => {
        'x-apisports-key': AppConstants.apiKey,
      };

  Future<List<FixtureModel>> getTodayFixtures() async {
    return getFixturesByDate(DateTime.now());
  }

  Future<List<FixtureModel>> getFixturesByDate(DateTime selectedDate) async {
    final date = _formatDate(selectedDate);

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

  Future<List<FixtureModel>> getLeagueFixtures(
    int leagueId, {
    int season = 2024,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?league=$leagueId&season=$season&timezone=Asia/Tehran',
    );

    return _fetchFixturesWithCache(
      cacheKey: 'league_${leagueId}_season_$season',
      url: url,
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<List<StandingModel>> getLeagueStandings(
    int leagueId, {
    int season = 2024,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/standings?league=$leagueId&season=$season',
    );

    return _fetchStandingsWithCache(
      cacheKey: 'standings_v2_${leagueId}_season_$season',
      url: url,
      cacheDuration: const Duration(hours: 1),
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

    final persistentCache = await _readFixturePersistentCache(cacheKey);

    if (persistentCache != null && !persistentCache.isExpired(cacheDuration)) {
      debugPrint('PERSISTENT CACHE HIT: $cacheKey');
      _fixtureCache[cacheKey] = _CacheItem(data: persistentCache.data);
      return persistentCache.data;
    }

    debugPrint('CACHE MISS: $cacheKey');

    try {
      final data = await _fetchFixtures(url);
      _fixtureCache[cacheKey] = _CacheItem(data: data);
      await _saveFixturePersistentCache(cacheKey, data);

      return data;
    } catch (e) {
      if (cached != null) {
        debugPrint('CACHE STALE FALLBACK: $cacheKey');
        return cached.data;
      }

      if (persistentCache != null) {
        debugPrint('PERSISTENT CACHE STALE FALLBACK: $cacheKey');
        _fixtureCache[cacheKey] = _CacheItem(data: persistentCache.data);
        return persistentCache.data;
      }

      final demoData = await _demoFixturesForCache(cacheKey);

      if (demoData.isNotEmpty) {
        debugPrint('DEMO FIXTURE FALLBACK: $cacheKey');
        return demoData;
      }

      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<FixtureModel>> _demoFixturesForCache(String cacheKey) async {
    if (!await _isDemoFallbackEnabled()) {
      return const [];
    }

    if (cacheKey == 'live_fixtures') {
      return DemoFootballData.liveFixtures();
    }

    if (cacheKey.startsWith('today_')) {
      final date = DateTime.tryParse(cacheKey.replaceFirst('today_', ''));

      if (date != null) {
        return DemoFootballData.fixturesForDate(date);
      }
    }

    final leagueMatch = RegExp(r'^league_(\d+)_season_').firstMatch(cacheKey);

    if (leagueMatch != null) {
      final leagueId = int.tryParse(leagueMatch.group(1) ?? '');

      if (leagueId != null) {
        return DemoFootballData.leagueFixtures(leagueId);
      }
    }

    return const [];
  }

  Future<List<StandingModel>> _demoStandingsForCache(String cacheKey) async {
    if (!await _isDemoFallbackEnabled()) {
      return const [];
    }

    final leagueMatch =
        RegExp(r'^standings(?:_v\d+)?_(\d+)_season_').firstMatch(cacheKey);

    if (leagueMatch == null) {
      return const [];
    }

    final leagueId = int.tryParse(leagueMatch.group(1) ?? '');

    if (leagueId == null) {
      return const [];
    }

    return DemoFootballData.standingsForLeague(leagueId);
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

    final persistentCache = await _readStandingPersistentCache(cacheKey);

    if (persistentCache != null && !persistentCache.isExpired(cacheDuration)) {
      debugPrint('PERSISTENT CACHE HIT: $cacheKey');
      _standingsCache[cacheKey] = _CacheItem(data: persistentCache.data);
      return persistentCache.data;
    }

    debugPrint('CACHE MISS: $cacheKey');

    try {
      final data = await _fetchStandings(url);
      _standingsCache[cacheKey] = _CacheItem(data: data);
      await _saveStandingPersistentCache(cacheKey, data);

      return data;
    } catch (e) {
      if (cached != null) {
        debugPrint('CACHE STALE FALLBACK: $cacheKey');
        return cached.data;
      }

      if (persistentCache != null) {
        debugPrint('PERSISTENT CACHE STALE FALLBACK: $cacheKey');
        _standingsCache[cacheKey] = _CacheItem(data: persistentCache.data);
        return persistentCache.data;
      }

      final demoData = await _demoStandingsForCache(cacheKey);

      if (demoData.isNotEmpty) {
        debugPrint('DEMO STANDINGS FALLBACK: $cacheKey');
        return demoData;
      }

      rethrow;
    }
  }

  Future<void> _saveFixturePersistentCache(
    String cacheKey,
    List<FixtureModel> data,
  ) async {
    final rawData = data.map((fixture) => fixture.toJson()).toList();
    await _savePersistentCache(cacheKey, rawData);
  }

  Future<void> _saveStandingPersistentCache(
    String cacheKey,
    List<StandingModel> data,
  ) async {
    final rawData = data.map((standing) => standing.toJson()).toList();
    await _savePersistentCache(cacheKey, rawData);
  }

  Future<void> _savePersistentCache(
    String cacheKey,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'createdAt': DateTime.now().toIso8601String(),
      'data': data,
    };

    await prefs.setString(_persistentCacheKey(cacheKey), jsonEncode(payload));
  }

  Future<_CacheItem<List<FixtureModel>>?> _readFixturePersistentCache(
    String cacheKey,
  ) async {
    final rawData = await _readPersistentCache(cacheKey);

    if (rawData == null) {
      return null;
    }

    final fixtures = rawData.data.map((json) {
      return FixtureModel.fromJson(json);
    }).toList();

    return _CacheItem(
      data: fixtures,
      createdAt: rawData.createdAt,
    );
  }

  Future<_CacheItem<List<StandingModel>>?> _readStandingPersistentCache(
    String cacheKey,
  ) async {
    final rawData = await _readPersistentCache(cacheKey);

    if (rawData == null) {
      return null;
    }

    final standings = rawData.data.map((json) {
      return StandingModel.fromJson(json);
    }).toList();

    return _CacheItem(
      data: standings,
      createdAt: rawData.createdAt,
    );
  }

  Future<_PersistentCacheData?> _readPersistentCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawPayload = prefs.getString(_persistentCacheKey(cacheKey));

      if (rawPayload == null) {
        return null;
      }

      final payload = jsonDecode(rawPayload) as Map<String, dynamic>;
      final createdAt = DateTime.tryParse(payload['createdAt'] ?? '');
      final List rawData = payload['data'] ?? [];

      if (createdAt == null) {
        return null;
      }

      final data = rawData.whereType<Map>().map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      return _PersistentCacheData(
        createdAt: createdAt,
        data: data,
      );
    } catch (e) {
      debugPrint('PERSISTENT CACHE READ ERROR: $cacheKey $e');
      return null;
    }
  }

  String _persistentCacheKey(String cacheKey) {
    return '${_persistentCachePrefix}_$cacheKey';
  }

  Future<List<FixtureModel>> _fetchFixtures(Uri url) async {
    try {
      debugPrint('API URL: $url');

      final response = await _getWithRetry(url);

      debugPrint('STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _throwIfApiErrors(data['errors']);

        final List fixtures = data['response'] ?? [];

        return fixtures.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API EXCEPTION: $e');
      throw Exception('Failed to load fixtures: $e');
    }
  }

  Future<List<StandingModel>> _fetchStandings(Uri url) async {
    try {
      debugPrint('API URL: $url');

      final response = await _getWithRetry(url);

      debugPrint('STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _throwIfApiErrors(data['errors']);

        final List responseList = data['response'] ?? [];

        if (responseList.isEmpty) {
          return [];
        }

        final standingsData = responseList[0]['league']?['standings'];

        if (standingsData == null || standingsData.isEmpty) {
          return [];
        }

        final standings = <StandingModel>[];

        for (final table in standingsData) {
          if (table is! List) {
            continue;
          }

          for (final item in table) {
            if (item is! Map) {
              continue;
            }

            standings.add(
              StandingModel.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }

        return standings;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API EXCEPTION: $e');
      throw Exception('Failed to load standings: $e');
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
        return DemoFootballData.matchDetailsForFixture(fixtureId);
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

      final demoDetail = DemoFootballData.matchDetailsForFixture(fixtureId);

      if (await _isDemoFallbackEnabled() && demoDetail != null) {
        debugPrint('DEMO MATCH DETAIL FALLBACK: $fixtureId');
        return demoDetail;
      }

      throw Exception(
        'Failed to load match details: $e',
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

    final squadUrl = Uri.parse(
      '${AppConstants.baseUrl}/players/squads?team=$teamId',
    );

    final coachesUrl = Uri.parse(
      '${AppConstants.baseUrl}/coachs?team=$teamId',
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

      final squadResponse = await _fetchOptionalResponseList(
        squadUrl,
        'team squad',
      );

      final coachesResponse = await _fetchOptionalResponseList(
        coachesUrl,
        'team coach',
      );

      final recentFixtures = fixturesResponse
          .map((json) => FixtureModel.fromJson(json))
          .toList();

      final squad = _parseTeamSquad(squadResponse);
      final coach = _parseTeamCoach(coachesResponse);
      final lineup = await _findRecentTeamLineup(teamId, recentFixtures);

      return TeamDetailsModel(
        team: TeamModel.fromJson(teamResponse[0]),
        recentFixtures: recentFixtures,
        squad: squad,
        coach: coach,
        lineup: lineup,
      );
    } catch (e) {
      debugPrint('TEAM DETAILS ERROR: $e');

      final demoDetails = DemoFootballData.teamDetailsForTeam(teamId);

      if (await _isDemoFallbackEnabled() && demoDetails != null) {
        debugPrint('DEMO TEAM DETAILS FALLBACK: $teamId');
        return demoDetails;
      }

      throw Exception('Failed to load team details: $e');
    }
  }

  List<TeamPlayerModel> _parseTeamSquad(List<dynamic> responseList) {
    if (responseList.isEmpty) {
      return [];
    }

    final List players = responseList[0]['players'] ?? [];

    return players.map((json) => TeamPlayerModel.fromJson(json)).toList();
  }

  TeamCoachModel? _parseTeamCoach(List<dynamic> responseList) {
    if (responseList.isEmpty) {
      return null;
    }

    return TeamCoachModel.fromJson(responseList[0]);
  }

  Future<TeamLineupSummaryModel?> _findRecentTeamLineup(
    int teamId,
    List<FixtureModel> fixtures,
  ) async {
    for (final fixture in fixtures.take(5)) {
      final lineupsUrl = Uri.parse(
        '${AppConstants.baseUrl}/fixtures/lineups?fixture=${fixture.id}',
      );

      final lineupsResponse = await _fetchOptionalResponseList(
        lineupsUrl,
        'team recent lineup',
      );

      for (final lineupJson in lineupsResponse) {
        if (lineupJson['team']?['id'] == teamId) {
          return TeamLineupSummaryModel.fromJson(lineupJson);
        }
      }
    }

    return null;
  }

  Future<List<TeamModel>> searchTeams(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      return [];
    }

    final cacheKey = trimmedQuery.toLowerCase();
    final cached = _teamSearchCache[cacheKey];

    if (cached != null && !cached.isExpired(const Duration(minutes: 30))) {
      debugPrint('TEAM SEARCH CACHE HIT: $cacheKey');
      return cached.data;
    }

    final url = Uri.parse(
      '${AppConstants.baseUrl}/teams?search=${Uri.encodeQueryComponent(trimmedQuery)}',
    );

    try {
      final responseList = await _fetchResponseList(url);

      final teams = responseList.map((json) {
        return TeamModel.fromJson(json);
      }).toList();
      _teamSearchCache[cacheKey] = _CacheItem(data: teams);

      return teams;
    } catch (e) {
      debugPrint('TEAM SEARCH ERROR: $e');

      if (await _isDemoFallbackEnabled()) {
        debugPrint('DEMO TEAM SEARCH FALLBACK: $trimmedQuery');
        return DemoFootballData.searchTeams(trimmedQuery);
      }

      throw Exception('Failed to search teams: $e');
    }
  }

  Future<List<LeagueModel>> searchLeagues(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      return [];
    }

    final cacheKey = trimmedQuery.toLowerCase();
    final cached = _leagueSearchCache[cacheKey];

    if (cached != null && !cached.isExpired(const Duration(minutes: 30))) {
      debugPrint('LEAGUE SEARCH CACHE HIT: $cacheKey');
      return cached.data;
    }

    final url = Uri.parse(
      '${AppConstants.baseUrl}/leagues?search=${Uri.encodeQueryComponent(trimmedQuery)}',
    );

    try {
      final responseList = await _fetchResponseList(url);

      final leagues = responseList.map((json) {
        final league = json['league'] ?? {};
        final country = json['country'] ?? {};
        final seasons = json['seasons'] is List ? json['seasons'] as List : [];
        final season = _pickLeagueSeason(seasons);

        return LeagueModel(
          id: league['id'] ?? 0,
          name: league['name'] ?? 'Unknown league',
          country: country['name'] ?? 'Unknown',
          season: season.toString(),
          apiSeason: season,
          logoUrl: league['logo'] ?? '',
          fallbackIcon: Icons.emoji_events_rounded,
        );
      }).where((league) => league.id != 0).toList();
      _leagueSearchCache[cacheKey] = _CacheItem(data: leagues);

      return leagues;
    } catch (e) {
      debugPrint('LEAGUE SEARCH ERROR: $e');

      if (await _isDemoFallbackEnabled()) {
        debugPrint('DEMO LEAGUE SEARCH FALLBACK: $trimmedQuery');
        return DemoFootballData.searchLeagues(trimmedQuery);
      }

      throw Exception('Failed to search leagues: $e');
    }
  }

  int _pickLeagueSeason(List seasons) {
    const latestFreeSeason = 2024;

    if (seasons.isEmpty) {
      return latestFreeSeason;
    }

    final years = seasons
        .whereType<Map>()
        .map((season) => season['year'])
        .whereType<int>()
        .where((year) => year <= latestFreeSeason)
        .toList();

    if (years.isEmpty) {
      return latestFreeSeason;
    }

    years.sort();
    return years.last;
  }

  Future<List<dynamic>> _fetchResponseList(Uri url) async {
    debugPrint('API URL: $url');

    final response = await _getWithRetry(url);

    debugPrint('STATUS: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    _throwIfApiErrors(data['errors']);

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
    _ensureApiEnabled();

    final requestKey = url.toString();
    final inFlightRequest = _inFlightRequests[requestKey];

    if (inFlightRequest != null) {
      debugPrint('API IN-FLIGHT HIT: $url');
      return inFlightRequest;
    }

    final request = _performGetWithRetry(url);
    _inFlightRequests[requestKey] = request;

    request.then(
      (_) {
        _inFlightRequests.remove(requestKey);
      },
      onError: (_) {
        _inFlightRequests.remove(requestKey);
      },
    );

    return request;
  }

  Future<http.Response> _performGetWithRetry(Uri url) async {
    const maxAttempts = 3;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await _waitForRequestSlot();

        return await http
            .get(url, headers: _headers)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        if (attempt == maxAttempts || !_shouldRetryRequest(e)) {
          rethrow;
        }

        debugPrint('API RETRY $attempt/$maxAttempts: $e');
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    throw Exception('API request failed');
  }

  bool _shouldRetryRequest(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('api is disabled') ||
        message.contains('api key is missing') ||
        message.contains('suspended') ||
        message.contains('free plan') ||
        message.contains('401') ||
        message.contains('403')) {
      return false;
    }

    return true;
  }

  void _ensureApiEnabled() {
    if (!AppConstants.apiEnabled) {
      throw Exception(
        'API is disabled in .env. Set API_ENABLED=true only when you want to use real API requests.',
      );
    }

    if (AppConstants.apiKey.isEmpty) {
      throw Exception('API key is missing. Add API_KEY to .env.');
    }
  }

  Future<bool> _isDemoFallbackEnabled() async {
    if (!AppConstants.demoFallbackEnabled) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('demo_fallback_enabled') ?? true;
  }

  Future<void> _waitForRequestSlot() {
    final nextRequest = _requestQueue.then((_) async {
      final interval = Duration(milliseconds: AppConstants.apiRequestIntervalMs);
      final lastRequestAt = _lastRequestAt;

      if (lastRequestAt != null) {
        final elapsed = DateTime.now().difference(lastRequestAt);

        if (elapsed < interval) {
          await Future.delayed(interval - elapsed);
        }
      }

      _lastRequestAt = DateTime.now();
    });

    _requestQueue = nextRequest.catchError((_) {});

    return nextRequest;
  }

  void _throwIfApiErrors(dynamic errors) {
    if (errors == null) {
      return;
    }

    if (errors is Map && errors.isEmpty) {
      return;
    }

    if (errors is List && errors.isEmpty) {
      return;
    }

    if (errors.toString() == '{}' || errors.toString() == '[]') {
      return;
    }

    debugPrint('API ERRORS: $errors');

    final message = errors.toString().toLowerCase();

    if (message.contains('suspended')) {
      throw Exception(
        'API account is suspended. Disable API requests or update your API key from the API-Football dashboard.',
      );
    }

    if (message.contains('free plans') || message.contains('plan')) {
      throw Exception(
        'This API endpoint or season is not available on the free plan.',
      );
    }

    throw Exception('API returned an error: $errors');
  }
}

class _CacheItem<T> {
  final T data;
  final DateTime createdAt;

  _CacheItem({
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool isExpired(Duration duration) {
    return DateTime.now().difference(createdAt) > duration;
  }
}

class _PersistentCacheData {
  final DateTime createdAt;
  final List<Map<String, dynamic>> data;

  _PersistentCacheData({
    required this.createdAt,
    required this.data,
  });
}
