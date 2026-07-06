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
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Leagues'),
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
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
            onPressed: () {
              provider.loadTodayFixtures();
            },
            icon: const Icon(Icons.refresh_rounded),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadTodayFixtures,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _searchBox(context),
            const SizedBox(height: 20),
            const Text(
              "TODAY'S MATCHES",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

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
              ...provider.todayFixtures.map((fixture) {
                return _fixtureCard(fixture);
              }),
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
                  fixture.leagueName,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Text(
                fixture.status,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _team(fixture.homeTeam, fixture.homeLogo)),
              Text(
                '$homeScore - $awayScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
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
        CachedNetworkImage(
          imageUrl: logo,
          width: 42,
          height: 42,
          placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
          errorWidget: (_, __, ___) => const Icon(
            Icons.shield_rounded,
            color: Colors.greenAccent,
          ),
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