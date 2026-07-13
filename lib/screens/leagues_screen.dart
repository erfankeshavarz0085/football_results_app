import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/league_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/team_provider.dart';
import 'league_details/league_details_screen.dart';

class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({super.key});

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  static const _featuredLeagueIds = <int>[
    39, // Premier League
    140, // La Liga
    135, // Serie A
    78, // Bundesliga
    61, // Ligue 1
    2, // UEFA Champions League
    1, // FIFA World Cup
    290, // Persian Gulf Pro League (Iran)
  ];

  String searchQuery = '';

  List<LeagueModel> filteredLeagues(List<LeagueModel> leagues) {
    final sorted = [...leagues]..sort(_compareLeagues);
    if (searchQuery.trim().isEmpty) return sorted;

    final query = searchQuery.toLowerCase().trim();

    return sorted.where((league) {
      final name = league.name.toLowerCase();
      final country = league.country.toLowerCase();

      return name.contains(query) || country.contains(query);
    }).toList();
  }

  int _compareLeagues(LeagueModel a, LeagueModel b) {
    final aIndex = _featuredLeagueIds.indexOf(a.id);
    final bIndex = _featuredLeagueIds.indexOf(b.id);
    if (aIndex >= 0 || bIndex >= 0) {
      if (aIndex < 0) return 1;
      if (bIndex < 0) return -1;
      return aIndex.compareTo(bIndex);
    }
    final country = a.country.compareTo(b.country);
    return country != 0 ? country : a.name.compareTo(b.name);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<TeamProvider>(context, listen: false).loadCurrentLeagues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeamProvider>(context);
    final data = filteredLeagues(provider.currentLeagues);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _topHeader(),
            const SizedBox(height: 16),
            _searchBox(),
            const SizedBox(height: 22),
            _sectionHeader(data.length),
            const SizedBox(height: 12),
            if (provider.isLeaguesLoading && data.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                ),
              )
            else if (provider.leaguesErrorMessage != null && data.isEmpty)
              _errorBox(provider)
            else if (data.isEmpty)
              _emptyBox()
            else
              ...data.map((league) => _leagueCard(context, league)),
          ],
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff132015), Color(0xff111827)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.greenAccent,
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leagues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Browse competitions, fixtures and standings',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search leagues or countries...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.greenAccent),
        suffixIcon:
            searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
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

  Widget _sectionHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Featured & Current Competitions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '$count leagues',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _leagueCard(BuildContext context, LeagueModel league) {
    final favorites = Provider.of<FavoriteProvider>(context);
    final isFavorite = favorites.isFavoriteLeague(league.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: CachedNetworkImage(
              imageUrl: league.logoUrl,
              fit: BoxFit.contain,
              errorWidget:
                  (_, __, ___) =>
                      Icon(league.fallbackIcon, color: Colors.black),
            ),
          ),
        ),
        title: Text(
          league.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            league.country,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => favorites.toggleFavoriteLeague(league),
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.redAccent : Colors.grey,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.greenAccent,
              size: 16,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => LeagueDetailsScreen(
                    leagueId: league.id,
                    leagueName: league.name,
                    initialLeague: league,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Text('No leagues found', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _errorBox(TeamProvider provider) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            provider.leaguesErrorMessage ?? 'Could not load leagues',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => provider.loadCurrentLeagues(forceRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
