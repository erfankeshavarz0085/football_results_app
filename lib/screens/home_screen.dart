import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fixture_model.dart';
import '../providers/fixture_provider.dart';
import 'favorites_screen.dart';
import 'leagues_screen.dart';
import 'live_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    LiveScreen(),
    LeaguesScreen(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'Leagues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
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
  final List<String> importantLeagues = const [
    'Premier League',
    'La Liga',
    'Serie A',
    'Bundesliga',
    'Ligue 1',
    'UEFA Champions League',
    'Champions League',
    'World Cup',
    'FIFA World Cup',
  ];

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

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Football Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: provider.loadTodayFixtures,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.greenAccent,
        onRefresh: provider.loadTodayFixtures,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(provider.todayFixtures.length),
            const SizedBox(height: 16),
            _searchBox(context),
            const SizedBox(height: 20),

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
            else
              ..._buildGroupedMatches(provider.todayFixtures),
          ],
        ),
      ),
    );
  }

  Widget _header(int matchCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff132015),
            Color(0xff111827),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.sports_soccer, color: Colors.black, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Matches",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$matchCount matches available today',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              'Search teams, leagues, matches...',
              style: TextStyle(color: Colors.grey),
            ),
            Spacer(),
            Icon(Icons.tune_rounded, color: Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedMatches(List<FixtureModel> fixtures) {
    final Map<String, List<FixtureModel>> grouped = {};

    for (final fixture in fixtures) {
      final leagueName = fixture.leagueName.trim();

      final isImportant = importantLeagues.any(
        (league) => leagueName.toLowerCase().contains(league.toLowerCase()),
      );

      final key = isImportant ? leagueName : 'Other Matches';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(fixture);
    }

    final orderedKeys = grouped.keys.toList();

    orderedKeys.sort((a, b) {
      if (a == 'Other Matches') return 1;
      if (b == 'Other Matches') return -1;
      return a.compareTo(b);
    });

    return orderedKeys.map((leagueName) {
      final matches = grouped[leagueName] ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leagueTitle(leagueName, matches.length),
          const SizedBox(height: 10),
          ...matches.map((match) => _fixtureCard(match)),
          const SizedBox(height: 18),
        ],
      );
    }).toList();
  }

  Widget _leagueTitle(String title, int count) {
    return Row(
      children: [
        Icon(
          title == 'Other Matches'
              ? Icons.public_rounded
              : Icons.emoji_events_rounded,
          color: Colors.greenAccent,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '$count matches',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _fixtureCard(FixtureModel fixture) {
    final homeScore = fixture.homeScore?.toString() ?? '-';
    final awayScore = fixture.awayScore?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fixture.status,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _team(fixture.homeTeam, fixture.homeLogo)),
              Text(
                '$homeScore - $awayScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(child: _team(fixture.awayTeam, fixture.awayLogo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _team(String name, String logo) {
    return Column(
      children: [
        if (logo.isNotEmpty)
          CachedNetworkImage(
            imageUrl: logo,
            width: 40,
            height: 40,
            placeholder: (_, __) => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.shield_rounded, color: Colors.black),
            ),
          )
        else
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.shield_rounded, color: Colors.black),
          ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}