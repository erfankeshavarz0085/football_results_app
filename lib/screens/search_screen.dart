import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  final teams = [
    {'name': 'Liverpool', 'league': 'Premier League'},
    {'name': 'Chelsea', 'league': 'Premier League'},
    {'name': 'Barcelona', 'league': 'La Liga'},
    {'name': 'Real Madrid', 'league': 'La Liga'},
    {'name': 'Inter Milan', 'league': 'Serie A'},
    {'name': 'Juventus', 'league': 'Serie A'},
    {'name': 'Bayern Munich', 'league': 'Bundesliga'},
    {'name': 'PSG', 'league': 'Ligue 1'},
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
                team['name'].toString(),
                team['league'].toString(),
              );
            }),
        ],
      ),
    );
  }

  Widget _teamCard(String name, String league) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.shield_rounded, color: Colors.black),
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
            Icons.favorite_border_rounded,
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}