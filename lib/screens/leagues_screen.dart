import 'package:flutter/material.dart';
import 'standings_screen.dart';

class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leagues = [
      {'name': 'Premier League', 'country': 'England', 'id': 39},
      {'name': 'La Liga', 'country': 'Spain', 'id': 140},
      {'name': 'Serie A', 'country': 'Italy', 'id': 135},
      {'name': 'Bundesliga', 'country': 'Germany', 'id': 78},
      {'name': 'Ligue 1', 'country': 'France', 'id': 61},
      {'name': 'Champions League', 'country': 'Europe', 'id': 2},
    ];

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Top Leagues',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leagues.length,
        itemBuilder: (context, index) {
          final league = leagues[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: Icon(Icons.emoji_events, color: Colors.black),
              ),
              title: Text(
                league['name'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                league['country'].toString(),
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.greenAccent,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StandingsScreen(
                      leagueName: league['name'].toString(),
                      leagueId: league['id'] as int,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}