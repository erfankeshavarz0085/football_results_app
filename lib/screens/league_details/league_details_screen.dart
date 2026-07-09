import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/league_model.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recent_view_provider.dart';
import 'tabs/fixtures_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/standings_tab.dart';

class LeagueDetailsScreen extends StatefulWidget {
  final int leagueId;
  final String leagueName;
  final LeagueModel? initialLeague;

  const LeagueDetailsScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
    this.initialLeague,
  });

  @override
  State<LeagueDetailsScreen> createState() => _LeagueDetailsScreenState();
}

class _LeagueDetailsScreenState extends State<LeagueDetailsScreen> {
  bool _didSaveRecentView = false;

  @override
  Widget build(BuildContext context) {
    final league = widget.initialLeague ??
        LeagueCatalog.byId(widget.leagueId, widget.leagueName);
    final info = league.toOverviewMap();

    if (!_didSaveRecentView) {
      _didSaveRecentView = true;
      Future.microtask(() {
        if (!mounted) return;

        Provider.of<RecentViewProvider>(
          context,
          listen: false,
        ).addLeague(league);
      });
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xff0d1117),
        body: SafeArea(
          child: Column(
            children: [
              _header(context, league, info),
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
                    FixturesTab(
                      leagueId: widget.leagueId,
                      leagueName: widget.leagueName,
                      season: league.apiSeason,
                    ),
                    StandingsTab(
                      leagueId: widget.leagueId,
                      leagueName: widget.leagueName,
                      season: league.apiSeason,
                    ),
                    HistoryTab(
                      leagueId: widget.leagueId,
                      leagueName: widget.leagueName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    LeagueModel league,
    Map<String, dynamic> info,
  ) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavoriteLeague(league.id);

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
              IconButton(
                onPressed: () => favoriteProvider.toggleFavoriteLeague(league),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
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
