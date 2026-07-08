import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/league_model.dart';
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
    final league = LeagueCatalog.byId(leagueId, leagueName);
    final info = league.toOverviewMap();

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
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CachedNetworkImage(
              imageUrl: info['logoUrl'],
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Icon(
                info['icon'],
                color: Colors.black,
                size: 36,
              ),
            ),
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

}
