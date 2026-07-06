import 'package:flutter/material.dart';

import 'league_details_screen.dart';

class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leagues = [
      {'id': 39, 'name': 'Premier League', 'country': 'England'},
      {'id': 140, 'name': 'La Liga', 'country': 'Spain'},
      {'id': 135, 'name': 'Serie A', 'country': 'Italy'},
      {'id': 78, 'name': 'Bundesliga', 'country': 'Germany'},
      {'id': 61, 'name': 'Ligue 1', 'country': 'France'},
      {'id': 2, 'name': 'Champions League', 'country': 'Europe'},
      {'id': 1, 'name': 'World Cup 2026', 'country': 'International'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Leagues',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leagues.length,
        itemBuilder: (context, index) {
          final league = leagues[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ListTile(
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
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeagueDetailsScreen(
                      leagueId: league['id'] as int,
                      leagueName: league['name'].toString(),
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