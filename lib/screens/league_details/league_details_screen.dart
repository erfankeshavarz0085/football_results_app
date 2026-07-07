import 'package:flutter/material.dart';

import 'tabs/fixtures_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/standings_tab.dart';

class LeagueDetailsScreen extends StatelessWidget {
  final int leagueId;
  final String leagueName;

  const LeagueDetailsScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    final info = _leagueInfo(leagueId, leagueName);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xff0d1117),
        body: SafeArea(
          child: Column(
            children: [
              _header(context, info),
              const TabBar(
                indicatorColor: Colors.greenAccent,
                labelColor: Colors.greenAccent,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Fixtures'),
                  Tab(text: 'Standings'),
                  Tab(text: 'History'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    OverviewTab(leagueInfo: info),
                    FixturesTab(leagueId: leagueId, leagueName: leagueName),
                    StandingsTab(leagueId: leagueId, leagueName: leagueName),
                    HistoryTab(leagueId: leagueId, leagueName: leagueName),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Map<String, dynamic> info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff132015), Color(0xff111827)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const Spacer(),
            ],
          ),
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.greenAccent,
            child: Icon(info['icon'], color: Colors.black, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            info['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${info['country']} • Season ${info['season']}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _leagueInfo(int id, String fallbackName) {
    switch (id) {
      case 39:
        return {
          'id': id,
          'name': 'Premier League',
          'country': 'England',
          'season': '2024/2025',
          'icon': Icons.sports_soccer,
        };
      case 140:
        return {
          'id': id,
          'name': 'La Liga',
          'country': 'Spain',
          'season': '2024/2025',
          'icon': Icons.sports_soccer,
        };
      case 135:
        return {
          'id': id,
          'name': 'Serie A',
          'country': 'Italy',
          'season': '2024/2025',
          'icon': Icons.sports_soccer,
        };
      case 78:
        return {
          'id': id,
          'name': 'Bundesliga',
          'country': 'Germany',
          'season': '2024/2025',
          'icon': Icons.sports_soccer,
        };
      case 61:
        return {
          'id': id,
          'name': 'Ligue 1',
          'country': 'France',
          'season': '2024/2025',
          'icon': Icons.sports_soccer,
        };
      case 2:
        return {
          'id': id,
          'name': 'Champions League',
          'country': 'Europe',
          'season': '2024/2025',
          'icon': Icons.emoji_events_rounded,
        };
      case 1:
        return {
          'id': id,
          'name': 'World Cup',
          'country': 'International',
          'season': '2026',
          'icon': Icons.public_rounded,
        };
      default:
        return {
          'id': id,
          'name': fallbackName,
          'country': 'Unknown',
          'season': '2024/2025',
          'icon': Icons.emoji_events_rounded,
        };
    }
  }
}