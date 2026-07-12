import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/league_model.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recent_view_provider.dart';
import '../../services/api_service.dart';
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
  late LeagueModel _league;
  late int _selectedSeason;

  @override
  void initState() {
    super.initState();
    _league =
        widget.initialLeague ??
        LeagueCatalog.byId(widget.leagueId, widget.leagueName);
    _selectedSeason = _league.apiSeason;
    _loadCompleteLeague();
  }

  Future<void> _loadCompleteLeague() async {
    try {
      final league = await ApiService().getLeague(widget.leagueId);
      if (!mounted || league == null) return;
      setState(() {
        _league = league;
        if (!league.availableSeasons.contains(_selectedSeason)) {
          _selectedSeason = league.apiSeason;
        }
      });
    } catch (_) {
      // The initial league remains usable if season metadata cannot be refreshed.
    }
  }

  @override
  Widget build(BuildContext context) {
    final league = _league;
    final info = league.toOverviewMap();

    if (!_didSaveRecentView) {
      _didSaveRecentView = true;
      final recentViewProvider = Provider.of<RecentViewProvider>(
        context,
        listen: false,
      );

      Future.microtask(() {
        if (!mounted) return;

        recentViewProvider.addLeague(league);
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
                      key: ValueKey(
                        'fixtures-${widget.leagueId}-$_selectedSeason',
                      ),
                      leagueId: widget.leagueId,
                      leagueName: widget.leagueName,
                      season: _selectedSeason,
                    ),
                    StandingsTab(
                      key: ValueKey(
                        'standings-${widget.leagueId}-$_selectedSeason',
                      ),
                      leagueId: widget.leagueId,
                      leagueName: widget.leagueName,
                      season: _selectedSeason,
                    ),
                    HistoryTab(
                      key: ValueKey(
                        'history-${widget.leagueId}-${league.availableSeasons.length}',
                      ),
                      leagueId: widget.leagueId,
                      leagueName: widget.leagueName,
                      seasons: league.availableSeasons,
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
              errorWidget:
                  (_, __, ___) =>
                      Icon(info['icon'], color: Colors.black, size: 36),
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
            '${info['country']} • Season $_selectedSeason',
            style: const TextStyle(color: Colors.white70),
          ),
          if (league.availableSeasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value:
                    league.availableSeasons.contains(_selectedSeason)
                        ? _selectedSeason
                        : null,
                hint: const Text('Select season'),
                dropdownColor: const Color(0xff161b22),
                iconEnabledColor: Colors.greenAccent,
                style: const TextStyle(color: Colors.white),
                items:
                    league.availableSeasons
                        .map(
                          (season) => DropdownMenuItem(
                            value: season,
                            child: Text('$season/${season + 1}'),
                          ),
                        )
                        .toList(),
                onChanged: (season) {
                  if (season == null || season == _selectedSeason) return;
                  setState(() => _selectedSeason = season);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
