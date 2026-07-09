import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/fixture_model.dart';
import '../providers/app_settings_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/fixture_provider.dart';
import '../providers/recent_view_provider.dart';
import 'favorites_screen.dart';
import 'league_details/league_details_screen.dart';
import 'leagues_screen.dart';
import 'live_screen.dart';
import 'match_details_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    LeaguesScreen(),
    LiveScreen(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  void _changePage(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff111827),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Leagues'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String searchQuery = '';

  final List<int> importantLeagueIds = const [39, 140, 135, 78, 61, 2, 1];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<FixtureProvider>(context, listen: false).loadTodayFixtures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final settings = Provider.of<AppSettingsProvider>(context);
    final filteredFixtures = _filterFixtures(provider.todayFixtures);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.greenAccent,
          onRefresh: provider.loadTodayFixtures,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _topHeader(
                matchCount: provider.todayFixtures.length,
                onRefresh: provider.loadTodayFixtures,
              ),
              if (settings.showFavoritesOnHome &&
                  favoriteProvider.isLoaded &&
                  (favoriteProvider.favoriteTeams.isNotEmpty ||
                      favoriteProvider.favoriteLeagues.isNotEmpty ||
                      favoriteProvider.followedMatches.isNotEmpty)) ...[
                const SizedBox(height: 16),
                _favoritesPreview(favoriteProvider),
              ],
              const SizedBox(height: 16),
              _todaySearchBox(),
              const SizedBox(height: 22),
              _sectionHeader(
                title: "Today's Fixtures",
                subtitle: searchQuery.isEmpty ? 'Grouped by league' : 'Search results',
              ),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  ),
                )
              else if (provider.errorMessage != null)
                _messageBox('خطا در دریافت اطلاعات')
              else if (provider.todayFixtures.isEmpty)
                _messageBox('مسابقه‌ای برای امروز پیدا نشد')
              else if (filteredFixtures.isEmpty)
                _messageBox('نتیجه‌ای برای جستجوی شما پیدا نشد')
              else
                ..._buildLeagueCards(filteredFixtures),
            ],
          ),
        ),
      ),
    );
  }

  List<FixtureModel> _filterFixtures(List<FixtureModel> fixtures) {
    if (searchQuery.trim().isEmpty) return fixtures;

    final query = searchQuery.toLowerCase().trim();

    return fixtures.where((fixture) {
      return fixture.homeTeam.toLowerCase().contains(query) ||
          fixture.awayTeam.toLowerCase().contains(query) ||
          fixture.leagueName.toLowerCase().contains(query) ||
          fixture.country.toLowerCase().contains(query);
    }).toList();
  }

  Widget _topHeader({
    required int matchCount,
    required VoidCallback onRefresh,
  }) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE • d MMMM').format(now);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff132015), Color(0xff111827)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.sports_soccer, color: Colors.black, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shoot Ball',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$formattedDate • $matchCount fixtures',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.greenAccent),
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_rounded, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  Widget _todaySearchBox() {
    return TextField(
      onChanged: (value) {
        setState(() => searchQuery = value);
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search today fixtures...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.greenAccent),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () {
                  setState(() => searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xff161b22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _favoritesPreview(FavoriteProvider favoriteProvider) {
    final teamCount = favoriteProvider.favoriteTeams.length;
    final leagueCount = favoriteProvider.favoriteLeagues.length;
    final matchCount = favoriteProvider.followedMatches.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$teamCount teams • $leagueCount leagues • $matchCount matches saved',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const Icon(
            Icons.favorite_rounded,
            color: Colors.greenAccent,
            size: 18,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeagueCards(List<FixtureModel> fixtures) {
    final Map<int, List<FixtureModel>> importantGroups = {};
    final List<FixtureModel> otherMatches = [];

    for (final fixture in fixtures) {
      if (importantLeagueIds.contains(fixture.leagueId)) {
        importantGroups.putIfAbsent(fixture.leagueId, () => []);
        importantGroups[fixture.leagueId]!.add(fixture);
      } else {
        otherMatches.add(fixture);
      }
    }

    final widgets = <Widget>[];

    final orderedImportantIds = importantLeagueIds
        .where((id) => importantGroups.containsKey(id))
        .toList();

    for (final leagueId in orderedImportantIds) {
      final matches = importantGroups[leagueId] ?? [];
      if (matches.isEmpty) continue;
      widgets.add(_leagueCard(matches.first, matches));
    }

    if (otherMatches.isNotEmpty) {
      widgets.add(_otherMatchesCard(otherMatches));
    }

    return widgets;
  }

  Widget _leagueCard(FixtureModel firstMatch, List<FixtureModel> matches) {
    final visibleMatches = matches.take(4).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leagueCardHeader(
            leagueName: firstMatch.leagueName,
            country: _displayCountry(firstMatch),
            logo: firstMatch.leagueLogo,
            count: matches.length,
            isOther: false,
          ),
          const SizedBox(height: 12),
          ...visibleMatches.map(
            (match) => _compactMatchRow(match, showCompetitionInfo: false),
          ),
          if (matches.length > 4) ...[
            const SizedBox(height: 8),
            _showAllButton(
              leagueId: firstMatch.leagueId,
              leagueName: firstMatch.leagueName,
            ),
          ],
        ],
      ),
    );
  }

  Widget _otherMatchesCard(List<FixtureModel> matches) {
    final visibleMatches = matches.take(6).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leagueCardHeader(
            leagueName: 'Other Matches',
            country: 'Various competitions',
            logo: '',
            count: matches.length,
            isOther: true,
          ),
          const SizedBox(height: 12),
          ...visibleMatches.map(
            (match) => _compactMatchRow(match, showCompetitionInfo: true),
          ),
          if (matches.length > 6) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${matches.length - 6} more fixtures',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _leagueCardHeader({
    required String leagueName,
    required String country,
    required String logo,
    required int count,
    required bool isOther,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xff0d1117),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: logo.isNotEmpty && !isOther
              ? CachedNetworkImage(
                  imageUrl: logo,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.greenAccent,
                  ),
                )
              : Icon(
                  isOther ? Icons.public_rounded : Icons.emoji_events_rounded,
                  color: Colors.greenAccent,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leagueName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                country,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '$count fixtures',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _showAllButton({
    required int leagueId,
    required String leagueName,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeagueDetailsScreen(
              leagueId: leagueId,
              leagueName: leagueName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
        ),
        child: const Center(
          child: Text(
            'Show All →',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactMatchRow(
    FixtureModel fixture, {
    required bool showCompetitionInfo,
  }) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFollowed = favoriteProvider.isFollowedMatch(fixture.id);

    return InkWell(
      onTap: () {
        Provider.of<RecentViewProvider>(
          context,
          listen: false,
        ).addMatch(fixture);
        _openMatchDetails(fixture.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          if (showCompetitionInfo) ...[
            Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.greenAccent,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_displayCountry(fixture)} • ${fixture.leagueName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => favoriteProvider.toggleFollowedMatch(fixture),
                  icon: Icon(
                    isFollowed
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isFollowed ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(child: _teamMini(fixture.homeTeam, fixture.homeLogo)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      _scoreOrTime(fixture),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatStatus(fixture.status),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _teamMini(fixture.awayTeam, fixture.awayLogo)),
              if (!showCompetitionInfo)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => favoriteProvider.toggleFollowedMatch(fixture),
                  icon: Icon(
                    isFollowed
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isFollowed ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
          if (fixture.round.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _cleanRound(fixture.round),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _openMatchDetails(int fixtureId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailsScreen(fixtureId: fixtureId),
      ),
    );
  }

  String _scoreOrTime(FixtureModel fixture) {
    if (fixture.status == 'NS') {
      return _formatMatchTime(fixture.date);
    }

    final homeScore = fixture.homeScore?.toString() ?? '-';
    final awayScore = fixture.awayScore?.toString() ?? '-';
    return '$homeScore - $awayScore';
  }

  String _formatMatchTime(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('HH:mm').format(parsedDate);
    } catch (_) {
      return '-';
    }
  }

  Widget _teamMini(String name, String logo) {
    return Column(
      children: [
        if (logo.isNotEmpty)
          CachedNetworkImage(
            imageUrl: logo,
            width: 34,
            height: 34,
            errorWidget: (_, __, ___) => const Icon(
              Icons.shield_rounded,
              color: Colors.greenAccent,
              size: 28,
            ),
          )
        else
          const Icon(
            Icons.shield_rounded,
            color: Colors.greenAccent,
            size: 28,
          ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }

  Widget _messageBox(String text) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'NS':
        return 'Not Started';
      case 'FT':
        return 'Full Time';
      case 'HT':
        return 'Half Time';
      case '1H':
      case '2H':
        return 'Live';
      default:
        return status;
    }
  }

  String _displayCountry(FixtureModel fixture) {
    if (fixture.leagueId == 2) return 'Europe';
    if (fixture.leagueId == 1) return 'International';
    if (fixture.country.toLowerCase() == 'world') return 'International';
    return fixture.country.isEmpty ? 'Unknown' : fixture.country;
  }

  String _cleanRound(String round) {
    return round
        .replaceAll('Regular Season - ', 'Matchweek ')
        .replaceAll('Qualification - ', 'Qualification • ')
        .replaceAll('League Stage - ', 'League Stage • ');
  }
}
