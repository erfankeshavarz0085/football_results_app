import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteTeams = [
      {'name': 'Liverpool', 'league': 'Premier League'},
      {'name': 'Barcelona', 'league': 'La Liga'},
      {'name': 'Inter Milan', 'league': 'Serie A'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favoriteTeams.isEmpty
          ? const Center(
              child: Text(
                'No favorite teams yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(),
                const SizedBox(height: 20),
                ...favoriteTeams.map((team) {
                  return _favoriteTeamCard(
                    team['name'].toString(),
                    team['league'].toString(),
                  );
                }),
              ],
            ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.favorite, color: Colors.black),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Your favorite teams will appear here for quick access.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteTeamCard(String name, String league) {
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
            Icons.arrow_forward_ios_rounded,
            color: Colors.greenAccent,
            size: 18,
          ),
        ],
      ),
    );
  }
}