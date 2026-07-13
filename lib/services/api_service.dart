import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fixture_model.dart';
import '../models/league_champion_model.dart';
import '../models/league_model.dart';
import '../models/standing_model.dart';
import '../models/team_model.dart';
import '../utils/constants.dart';
import '../utils/demo_football_data.dart';
import '../models/match_detail_model.dart';
import '../models/player_leader_model.dart';

class ApiService {
  static const String _persistentCachePrefix = 'api_cache';

  static final Map<String, _CacheItem<List<FixtureModel>>> _fixtureCache = {};
  static final Map<String, _CacheItem<List<StandingModel>>> _standingsCache =
      {};
  static final Map<String, _CacheItem<List<TeamModel>>> _teamSearchCache = {};
  static final Map<String, _CacheItem<List<LeagueModel>>> _leagueSearchCache =
      {};
  static _CacheItem<List<LeagueModel>>? _currentLeaguesCache;
  static final Map<String, _CacheItem<LeaguePlayerLeaders>>
  _playerLeadersCache = {};
  static final Map<String, Future<http.Response>> _inFlightRequests = {};
  static DateTime? _lastRequestAt;
  static Future<void> _requestQueue = Future.value();
  static ApiUsage? latestUsage;

  Map<String, String> get _headers => {'x-apisports-key': AppConstants.apiKey};

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
    int? season,
  }) async {
    season ??= AppConstants.currentSeason;
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
    int? season,
  }) async {
    season ??= AppConstants.currentSeason;
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

    final leagueMatch = RegExp(
      r'^standings(?:_v\d+)?_(\d+)_season_',
    ).firstMatch(cacheKey);

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

    final fixtures =
        rawData.data.map((json) {
          return FixtureModel.fromJson(json);
        }).toList();

    return _CacheItem(data: fixtures, createdAt: rawData.createdAt);
  }

  Future<_CacheItem<List<StandingModel>>?> _readStandingPersistentCache(
    String cacheKey,
  ) async {
    final rawData = await _readPersistentCache(cacheKey);

    if (rawData == null) {
      return null;
    }

    final standings =
        rawData.data.map((json) {
          return StandingModel.fromJson(json);
        }).toList();

    return _CacheItem(data: standings, createdAt: rawData.createdAt);
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

      final data =
          rawData.whereType<Map>().map((item) {
            return Map<String, dynamic>.from(item);
          }).toList();

      return _PersistentCacheData(createdAt: createdAt, data: data);
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

      final events =
          detailResults[0]
              .map((json) => MatchEventModel.fromJson(json))
              .toList();

      final statistics =
          detailResults[1]
              .map((json) => MatchStatisticModel.fromJson(json))
              .toList();

      final lineups =
          detailResults[2]
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

      throw Exception('Failed to load match details: $e');
    }
  }

  Future<TeamDetailsModel?> getTeamDetails(int teamId) async {
    final teamUrl = Uri.parse('${AppConstants.baseUrl}/teams?id=$teamId');

    final fixturesUrl = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?team=$teamId&last=10&timezone=Asia/Tehran',
    );

    final squadUrl = Uri.parse(
      '${AppConstants.baseUrl}/players/squads?team=$teamId',
    );

    final coachesUrl = Uri.parse('${AppConstants.baseUrl}/coachs?team=$teamId');

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

      final recentFixtures =
          fixturesResponse.map((json) => FixtureModel.fromJson(json)).toList();

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
    for (final fixture in fixtures.take(10)) {
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

      final teams =
          responseList.map((json) {
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

      final leagues =
          responseList
              .map(_leagueFromJson)
              .where((league) => league.id != 0)
              .toList();
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

  Future<List<LeagueModel>> getCurrentLeagues({
    bool forceRefresh = false,
  }) async {
    final cached = _currentLeaguesCache;
    if (!forceRefresh &&
        cached != null &&
        !cached.isExpired(const Duration(hours: 12))) {
      return cached.data;
    }

    final url = Uri.parse('${AppConstants.baseUrl}/leagues?current=true');
    final response = await _fetchResponseList(url);
    final leagues =
        response.map(_leagueFromJson).where((league) => league.id != 0).toList()
          ..sort((a, b) {
            final country = a.country.compareTo(b.country);
            return country != 0 ? country : a.name.compareTo(b.name);
          });
    _currentLeaguesCache = _CacheItem(data: leagues);
    return leagues;
  }

  Future<LeagueModel?> getLeague(int leagueId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/leagues?id=$leagueId');
    final response = await _fetchResponseList(url);
    if (response.isEmpty) return null;
    return _leagueFromJson(response.first);
  }

  Future<List<LeagueChampionModel>> getLeagueChampions(
    int leagueId,
    List<int> seasons,
  ) async {
    final champions = <LeagueChampionModel>[];
    for (final season in seasons
        .where((year) => year < AppConstants.currentSeason)
        .take(12)) {
      try {
        final standings = await getLeagueStandings(leagueId, season: season);
        if (standings.isEmpty) continue;
        standings.sort((a, b) => a.rank.compareTo(b.rank));
        final winner = standings.firstWhere(
          (item) => item.rank == 1,
          orElse: () => standings.first,
        );
        final runnerUp = standings.length > 1 ? standings[1].teamName : '';
        champions.add(
          LeagueChampionModel(
            season: '$season/${season + 1}',
            champion: winner.teamName,
            runnerUp: runnerUp,
          ),
        );
      } catch (e) {
        debugPrint('CHAMPION HISTORY $leagueId/$season ERROR: $e');
      }
    }
    return champions;
  }

  Future<LeaguePlayerLeaders> getLeaguePlayerLeaders(
    int leagueId,
    int season,
  ) async {
    final cacheKey = 'v2-$leagueId-$season';
    final cached = _playerLeadersCache[cacheKey];
    if (cached != null && !cached.isExpired(const Duration(hours: 6))) {
      return cached.data;
    }

    final responses = await Future.wait([
      _fetchResponseList(
        Uri.parse(
          '${AppConstants.baseUrl}/players/topscorers?league=$leagueId&season=$season',
        ),
      ),
      _fetchResponseList(
        Uri.parse(
          '${AppConstants.baseUrl}/players/topassists?league=$leagueId&season=$season',
        ),
      ),
      getLeagueFixtures(leagueId, season: season),
    ]);

    final scorers = _parsePlayerLeaders(
      responses[0],
      (stats) => stats['goals']?['total'] ?? 0,
    );
    final assists = _parsePlayerLeaders(
      responses[1],
      (stats) => stats['goals']?['assists'] ?? 0,
    );
    final cleanSheets = await _buildCleanSheetLeaders(
      responses[2] as List<FixtureModel>,
      leagueId,
      season,
    );

    final result = LeaguePlayerLeaders(
      scorers: scorers,
      assists: assists,
      cleanSheets: cleanSheets,
    );
    _playerLeadersCache[cacheKey] = _CacheItem(data: result);
    return result;
  }

  List<PlayerLeaderModel> _parsePlayerLeaders(
    List<dynamic> response,
    int Function(dynamic stats) valueOf,
  ) {
    return response
        .map((item) {
          final player = item['player'] ?? {};
          final List statistics = item['statistics'] ?? [];
          final stats = statistics.isEmpty ? {} : statistics.first;
          final team = stats['team'] ?? {};
          return PlayerLeaderModel(
            playerId: player['id'] ?? 0,
            playerName: player['name'] ?? 'Unknown player',
            playerPhoto: player['photo'] ?? '',
            teamId: team['id'] ?? 0,
            teamName: team['name'] ?? 'Unknown team',
            teamLogo: team['logo'] ?? '',
            value: valueOf(stats),
          );
        })
        .where((item) => item.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  Future<List<PlayerLeaderModel>> _buildCleanSheetLeaders(
    List<FixtureModel> fixtures,
    int leagueId,
    int season,
  ) async {
    final teams = <int, _TeamCleanSheets>{};
    for (final fixture in fixtures) {
      if (fixture.homeScore == null || fixture.awayScore == null) continue;
      teams.putIfAbsent(
        fixture.homeTeamId,
        () => _TeamCleanSheets(
          id: fixture.homeTeamId,
          name: fixture.homeTeam,
          logo: fixture.homeLogo,
        ),
      );
      teams.putIfAbsent(
        fixture.awayTeamId,
        () => _TeamCleanSheets(
          id: fixture.awayTeamId,
          name: fixture.awayTeam,
          logo: fixture.awayLogo,
        ),
      );
      if (fixture.awayScore == 0) teams[fixture.homeTeamId]!.count++;
      if (fixture.homeScore == 0) teams[fixture.awayTeamId]!.count++;
    }

    final ranked =
        teams.values.where((team) => team.count > 0).toList()
          ..sort((a, b) => b.count.compareTo(a.count));
    final leaders = <PlayerLeaderModel>[];
    for (final team in ranked.take(10)) {
      final players = await _fetchPaginatedResponse(
        Uri.parse(
          '${AppConstants.baseUrl}/players?team=${team.id}&league=$leagueId&season=$season',
        ),
      );
      dynamic bestGoalkeeper;
      var bestAppearances = -1;
      for (final item in players) {
        final List statistics = item['statistics'] ?? [];
        for (final stats in statistics) {
          if (stats['team']?['id'] != team.id ||
              stats['league']?['id'] != leagueId ||
              stats['games']?['position'] != 'Goalkeeper') {
            continue;
          }
          final appearances = stats['games']?['appearences'] ?? 0;
          if (appearances > bestAppearances) {
            bestAppearances = appearances;
            bestGoalkeeper = item['player'];
          }
        }
      }
      leaders.add(
        PlayerLeaderModel(
          playerId: bestGoalkeeper?['id'] ?? 0,
          playerName: bestGoalkeeper?['name'] ?? '${team.name} goalkeeper',
          playerPhoto: bestGoalkeeper?['photo'] ?? '',
          teamId: team.id,
          teamName: team.name,
          teamLogo: team.logo,
          value: team.count,
        ),
      );
    }
    return leaders;
  }

  Future<List<dynamic>> _fetchPaginatedResponse(Uri baseUrl) async {
    final allItems = <dynamic>[];
    var page = 1;
    var totalPages = 1;

    do {
      final url = baseUrl.replace(
        queryParameters: {...baseUrl.queryParameters, 'page': page.toString()},
      );
      final response = await _getWithRetry(url);
      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      _throwIfApiErrors(data['errors']);
      allItems.addAll(data['response'] ?? const []);
      totalPages = data['paging']?['total'] ?? 1;
      page++;
    } while (page <= totalPages);

    return allItems;
  }

  LeagueModel _leagueFromJson(dynamic json) {
    final league = json['league'] ?? {};
    final country = json['country'] ?? {};
    final rawSeasons = json['seasons'] is List ? json['seasons'] as List : [];
    final seasons =
        rawSeasons
            .whereType<Map>()
            .map((item) => item['year'])
            .whereType<int>()
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    final season = _pickLeagueSeason(rawSeasons);
    return LeagueModel(
      id: league['id'] ?? 0,
      name: league['name'] ?? 'Unknown league',
      country: country['name'] ?? 'Unknown',
      season: season.toString(),
      apiSeason: season,
      availableSeasons: seasons,
      logoUrl: league['logo'] ?? '',
      fallbackIcon: Icons.emoji_events_rounded,
    );
  }

  int _pickLeagueSeason(List seasons) {
    if (seasons.isEmpty) {
      return AppConstants.currentSeason;
    }

    final years =
        seasons
            .whereType<Map>()
            .map((season) => season['year'])
            .whereType<int>()
            .toList();

    if (years.isEmpty) {
      return AppConstants.currentSeason;
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

        final response = await http
            .get(url, headers: _headers)
            .timeout(const Duration(seconds: 15));
        _captureUsage(response);

        if (response.statusCode == 429 && attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        return response;
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

  void _captureUsage(http.Response response) {
    int? headerInt(String name) => int.tryParse(response.headers[name] ?? '');
    latestUsage = ApiUsage(
      dailyLimit: headerInt('x-ratelimit-requests-limit'),
      dailyRemaining: headerInt('x-ratelimit-requests-remaining'),
      minuteLimit: headerInt('x-ratelimit-limit'),
      minuteRemaining: headerInt('x-ratelimit-remaining'),
      updatedAt: DateTime.now(),
    );
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
    return prefs.getBool('demo_fallback_enabled') ?? false;
  }

  Future<void> _waitForRequestSlot() {
    final nextRequest = _requestQueue.then((_) async {
      final interval = Duration(
        milliseconds: AppConstants.apiRequestIntervalMs,
      );
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

class ApiUsage {
  final int? dailyLimit;
  final int? dailyRemaining;
  final int? minuteLimit;
  final int? minuteRemaining;
  final DateTime updatedAt;

  const ApiUsage({
    required this.dailyLimit,
    required this.dailyRemaining,
    required this.minuteLimit,
    required this.minuteRemaining,
    required this.updatedAt,
  });
}

class _TeamCleanSheets {
  final int id;
  final String name;
  final String logo;
  int count = 0;

  _TeamCleanSheets({required this.id, required this.name, required this.logo});
}

class _CacheItem<T> {
  final T data;
  final DateTime createdAt;

  _CacheItem({required this.data, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  bool isExpired(Duration duration) {
    return DateTime.now().difference(createdAt) > duration;
  }
}

class _PersistentCacheData {
  final DateTime createdAt;
  final List<Map<String, dynamic>> data;

  _PersistentCacheData({required this.createdAt, required this.data});
}
