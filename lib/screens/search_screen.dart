import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/team_model.dart';
import '../providers/team_provider.dart';
import 'team_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  Timer? _debounce;

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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => query = value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).searchTeams(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeamProvider>(context);
    final trimmedQuery = query.trim();
    final teams = trimmedQuery.length < 3 ? popularTeams : provider.searchResults;

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
          TextField(
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search teams...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () {
                        _debounce?.cancel();
                        setState(() => query = '');
                        Provider.of<TeamProvider>(
                          context,
                          listen: false,
                        ).searchTeams('');
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
          ),
          const SizedBox(height: 20),
          _searchHint(trimmedQuery),
          const SizedBox(height: 12),
          if (provider.isSearchLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
            )
          else if (provider.searchErrorMessage != null && trimmedQuery.length >= 3)
            _messageBox('Team search failed. Please try again.')
          else if (teams.isEmpty)
            _messageBox('No teams found')
          else
            ...teams.map(_teamCard),
        ],
      ),
    );
  }

  Widget _searchHint(String trimmedQuery) {
    final text = trimmedQuery.length < 3
        ? 'Popular teams. Type at least 3 letters to search all teams.'
        : 'Search results';

    return Text(
      text,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }

  Widget _teamCard(TeamModel team) {
    return InkWell(
      onTap: () {
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
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xff0d1117),
                borderRadius: BorderRadius.circular(14),
              ),
              child: team.logo.isEmpty
                  ? const Icon(
                      Icons.shield_rounded,
                      color: Colors.greenAccent,
                    )
                  : CachedNetworkImage(
                      imageUrl: team.logo,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.shield_rounded,
                        color: Colors.greenAccent,
                      ),
                    ),
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
