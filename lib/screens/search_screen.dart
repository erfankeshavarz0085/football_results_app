import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/league_model.dart';
import '../models/team_model.dart';
import '../providers/app_settings_provider.dart';
import '../providers/recent_view_provider.dart';
import '../providers/team_provider.dart';
import 'match_details_screen.dart';
import 'league_details/league_details_screen.dart';
import 'team_details_screen.dart';

enum SearchMode { teams, leagues }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _recentSearchesKey = 'recent_searches';

  String query = '';
  SearchMode searchMode = SearchMode.teams;
  Timer? _debounce;
  List<String> recentSearches = [];
  final TextEditingController _searchController = TextEditingController();

  final List<TeamModel> popularTeams = [
    TeamModel(
      id: 40,
      name: 'Liverpool',
      country: 'England',
      logo: 'https://media.api-sports.io/football/teams/40.png',
      founded: 0,
      venueName: '',
      venueCity: '',
      venueCapacity: 0,
    ),
    TeamModel(
      id: 49,
      name: 'Chelsea',
      country: 'England',
      logo: 'https://media.api-sports.io/football/teams/49.png',
      founded: 0,
      venueName: '',
      venueCity: '',
      venueCapacity: 0,
    ),
    TeamModel(
      id: 529,
      name: 'Barcelona',
      country: 'Spain',
      logo: 'https://media.api-sports.io/football/teams/529.png',
      founded: 0,
      venueName: '',
      venueCity: '',
      venueCapacity: 0,
    ),
    TeamModel(
      id: 541,
      name: 'Real Madrid',
      country: 'Spain',
      logo: 'https://media.api-sports.io/football/teams/541.png',
      founded: 0,
      venueName: '',
      venueCity: '',
      venueCapacity: 0,
    ),
    TeamModel(
      id: 505,
      name: 'Inter Milan',
      country: 'Italy',
      logo: 'https://media.api-sports.io/football/teams/505.png',
      founded: 0,
      venueName: '',
      venueCity: '',
      venueCapacity: 0,
    ),
    TeamModel(
      id: 157,
      name: 'Bayern Munich',
      country: 'Germany',
      logo: 'https://media.api-sports.io/football/teams/157.png',
      founded: 0,
      venueName: '',
      venueCity: '',
      venueCapacity: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String value) async {
    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return;
    }

    final updatedSearches = [
      trimmedValue,
      ...recentSearches.where((item) {
        return item.toLowerCase() != trimmedValue.toLowerCase();
      }),
    ].take(6).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, updatedSearches);

    if (!mounted) return;

    setState(() {
      recentSearches = updatedSearches;
    });
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);

    if (!mounted) return;

    setState(() {
      recentSearches = [];
    });
  }

  void _onSearchChanged(String value) {
    setState(() => query = value);

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      final provider = Provider.of<TeamProvider>(context, listen: false);

      if (searchMode == SearchMode.teams) {
        provider.searchTeams(value);
      } else {
        provider.searchLeagues(value);
      }
    });
  }

  void _changeMode(SearchMode mode) {
    setState(() {
      searchMode = mode;
    });

    _debounce?.cancel();

    if (mode == SearchMode.teams && query.trim().length >= 3) {
      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).searchTeams(query);
    } else if (mode == SearchMode.leagues && query.trim().length >= 3) {
      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).searchLeagues(query);
    }
  }

  void _applyRecentSearch(String value) {
    setState(() => query = value);
    _searchController.text = value;
    _searchController.selection = TextSelection.collapsed(
      offset: value.length,
    );

    if (searchMode == SearchMode.teams) {
      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).searchTeams(value);
    } else {
      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).searchLeagues(value);
    }
  }

  void _clearQuery() {
    _debounce?.cancel();
    setState(() => query = '');
    _searchController.clear();

    Provider.of<TeamProvider>(
      context,
      listen: false,
    ).searchTeams('');

    Provider.of<TeamProvider>(
      context,
      listen: false,
    ).searchLeagues('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeamProvider>(context);
    final recentViewProvider = Provider.of<RecentViewProvider>(context);
    final settings = Provider.of<AppSettingsProvider>(context);
    final trimmedQuery = query.trim();
    final teams = trimmedQuery.length < 3 ? popularTeams : provider.searchResults;
    final leagues = trimmedQuery.length < 3
        ? LeagueCatalog.topLeagues
        : provider.leagueSearchResults;

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _searchField(),
          const SizedBox(height: 14),
          _modeSelector(),
          const SizedBox(height: 18),
          if (query.isEmpty && recentSearches.isNotEmpty) ...[
            _recentSearches(),
            const SizedBox(height: 20),
          ],
          if (settings.showRecentlyViewedInSearch &&
              query.isEmpty &&
              recentViewProvider.items.isNotEmpty) ...[
            _recentViews(recentViewProvider),
            const SizedBox(height: 20),
          ],
          _searchHint(trimmedQuery),
          const SizedBox(height: 12),
          if (searchMode == SearchMode.teams)
            _teamResults(provider, trimmedQuery, teams)
          else
            _leagueResults(provider, trimmedQuery, leagues),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: searchMode == SearchMode.teams
            ? 'Search teams...'
            : 'Search leagues...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: _clearQuery,
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

  Widget _modeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _modeButton('Teams', SearchMode.teams),
          _modeButton('Leagues', SearchMode.leagues),
        ],
      ),
    );
  }

  Widget _modeButton(String label, SearchMode mode) {
    final isSelected = searchMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => _changeMode(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent searches',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: _clearRecentSearches,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((item) {
            return ActionChip(
              label: Text(item),
              backgroundColor: const Color(0xff161b22),
              labelStyle: const TextStyle(color: Colors.white70),
              side: const BorderSide(color: Colors.white10),
              onPressed: () => _applyRecentSearch(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _recentViews(RecentViewProvider recentViewProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recently viewed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: recentViewProvider.clear,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentViewProvider.items.take(6).map(_recentViewCard),
      ],
    );
  }

  Widget _recentViewCard(RecentViewItem item) {
    return InkWell(
      onTap: () => _openRecentView(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _logoBox(
              imageUrl: item.imageUrl,
              fallbackIcon: _recentViewIcon(item.type),
              useWhiteBackground: item.type == RecentViewType.league,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_recentViewLabel(item.type)} • ${item.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.greenAccent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _openRecentView(RecentViewItem item) {
    if (item.type == RecentViewType.match) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailsScreen(fixtureId: item.id),
        ),
      );
      return;
    }

    if (item.type == RecentViewType.team) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeamDetailsScreen(
            teamId: item.id,
            fallbackName: item.title,
            fallbackLogo: item.imageUrl,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeagueDetailsScreen(
          leagueId: item.id,
          leagueName: item.title,
          initialLeague: LeagueModel(
            id: item.id,
            name: item.title,
            country: item.subtitle,
            season: (item.season ?? 2024).toString(),
            apiSeason: item.season ?? 2024,
            logoUrl: item.imageUrl,
            fallbackIcon: Icons.emoji_events_rounded,
          ),
        ),
      ),
    );
  }

  IconData _recentViewIcon(RecentViewType type) {
    return switch (type) {
      RecentViewType.match => Icons.sports_soccer_rounded,
      RecentViewType.team => Icons.shield_rounded,
      RecentViewType.league => Icons.emoji_events_rounded,
    };
  }

  String _recentViewLabel(RecentViewType type) {
    return switch (type) {
      RecentViewType.match => 'Match',
      RecentViewType.team => 'Team',
      RecentViewType.league => 'League',
    };
  }

  Widget _searchHint(String trimmedQuery) {
    final text = switch (searchMode) {
      SearchMode.teams => trimmedQuery.length < 3
          ? 'Popular teams. Type at least 3 letters to search all teams.'
          : 'Team results',
      SearchMode.leagues => trimmedQuery.length < 3
          ? 'Top competitions'
          : 'League results',
    };

    return Text(
      text,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }

  Widget _teamResults(
    TeamProvider provider,
    String trimmedQuery,
    List<TeamModel> teams,
  ) {
    if (provider.isSearchLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    if (provider.searchErrorMessage != null && trimmedQuery.length >= 3) {
      return _messageBox(provider.searchErrorMessage!);
    }

    if (teams.isEmpty) {
      return _messageBox('No teams found');
    }

    return Column(
      children: teams.map(_teamCard).toList(),
    );
  }

  Widget _leagueResults(
    TeamProvider provider,
    String trimmedQuery,
    List<LeagueModel> leagues,
  ) {
    if (provider.isLeagueSearchLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    if (provider.leagueSearchErrorMessage != null && trimmedQuery.length >= 3) {
      return _messageBox(provider.leagueSearchErrorMessage!);
    }

    if (leagues.isEmpty) {
      return _messageBox('No leagues found');
    }

    return Column(
      children: leagues.map(_leagueCard).toList(),
    );
  }

  Widget _teamCard(TeamModel team) {
    return InkWell(
      onTap: () {
        _saveRecentSearch(team.name);
        Provider.of<RecentViewProvider>(
          context,
          listen: false,
        ).addTeamModel(team);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDetailsScreen(
              teamId: team.id,
              fallbackName: team.name,
              fallbackLogo: team.logo,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _logoBox(
              imageUrl: team.logo,
              fallbackIcon: Icons.shield_rounded,
              useWhiteBackground: false,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    team.country.isEmpty ? 'Unknown country' : team.country,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.greenAccent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _leagueCard(LeagueModel league) {
    return InkWell(
      onTap: () {
        _saveRecentSearch(league.name);
        Provider.of<RecentViewProvider>(
          context,
          listen: false,
        ).addLeague(league);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeagueDetailsScreen(
              leagueId: league.id,
              leagueName: league.name,
              initialLeague: league,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _logoBox(
              imageUrl: league.logoUrl,
              fallbackIcon: league.fallbackIcon,
              useWhiteBackground: true,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    league.country,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.greenAccent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoBox({
    required String imageUrl,
    required IconData fallbackIcon,
    required bool useWhiteBackground,
  }) {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: useWhiteBackground ? Colors.white : const Color(0xff0d1117),
        borderRadius: BorderRadius.circular(14),
      ),
      child: imageUrl.isEmpty
          ? Icon(
              fallbackIcon,
              color: useWhiteBackground ? Colors.black : Colors.greenAccent,
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Icon(
                fallbackIcon,
                color: useWhiteBackground ? Colors.black : Colors.greenAccent,
              ),
            ),
    );
  }

  Widget _messageBox(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
