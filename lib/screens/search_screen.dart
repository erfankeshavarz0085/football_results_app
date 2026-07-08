import 'package:flutter/material.dart';

import 'team_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  final teams = [
    {
      'id': 40,
      'name': 'Liverpool',
      'league': 'Premier League',
      'logo': 'https://media.api-sports.io/football/teams/40.png',
    },
    {
      'id': 49,
      'name': 'Chelsea',
      'league': 'Premier League',
      'logo': 'https://media.api-sports.io/football/teams/49.png',
    },
    {
      'id': 529,
      'name': 'Barcelona',
      'league': 'La Liga',
      'logo': 'https://media.api-sports.io/football/teams/529.png',
    },
    {
      'id': 541,
      'name': 'Real Madrid',
      'league': 'La Liga',
      'logo': 'https://media.api-sports.io/football/teams/541.png',
    },
    {
      'id': 505,
      'name': 'Inter Milan',
      'league': 'Serie A',
      'logo': 'https://media.api-sports.io/football/teams/505.png',
    },
    {
      'id': 496,
      'name': 'Juventus',
      'league': 'Serie A',
      'logo': 'https://media.api-sports.io/football/teams/496.png',
    },
    {
      'id': 157,
      'name': 'Bayern Munich',
      'league': 'Bundesliga',
      'logo': 'https://media.api-sports.io/football/teams/157.png',
    },
    {
      'id': 85,
      'name': 'PSG',
      'league': 'Ligue 1',
      'logo': 'https://media.api-sports.io/football/teams/85.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTeams = teams.where((team) {
      final name = team['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

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
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search teams...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
              filled: true,
              fillColor: const Color(0xff161b22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (filteredTeams.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text(
                  'No teams found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...filteredTeams.map((team) {
              return _teamCard(
                team['id'] as int,
                team['name'].toString(),
                team['league'].toString(),
                team['logo'].toString(),
              );
            }),
        ],
      ),
    );
  }

  Widget _teamCard(int teamId, String name, String league, String logo) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDetailsScreen(
              teamId: teamId,
              fallbackName: name,
              fallbackLogo: logo,
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
            CircleAvatar(
              backgroundColor: const Color(0xff0d1117),
              backgroundImage: NetworkImage(logo),
              child: logo.isEmpty
                  ? const Icon(Icons.shield_rounded, color: Colors.greenAccent)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    league,
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
}
