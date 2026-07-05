import 'package:flutter/material.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Live Matches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _liveHeader(),
          const SizedBox(height: 20),
          _liveMatchCard(
            league: 'Premier League',
            homeTeam: 'Liverpool',
            awayTeam: 'Chelsea',
            homeScore: 2,
            awayScore: 1,
            minute: '78',
          ),
          _liveMatchCard(
            league: 'La Liga',
            homeTeam: 'Barcelona',
            awayTeam: 'Real Madrid',
            homeScore: 1,
            awayScore: 1,
            minute: '64',
          ),
          _liveMatchCard(
            league: 'Serie A',
            homeTeam: 'Inter Milan',
            awayTeam: 'Juventus',
            homeScore: 0,
            awayScore: 0,
            minute: '52',
          ),
        ],
      ),
    );
  }

  Widget _liveHeader() {
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
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.sports_soccer, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Live football matches are updated in real time.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveMatchCard({
    required String league,
    required String homeTeam,
    required String awayTeam,
    required int homeScore,
    required int awayScore,
    required String minute,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                league,
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$minute’ LIVE",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _teamInfo(homeTeam)),
              Text(
                '$homeScore - $awayScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(child: _teamInfo(awayTeam)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(title: 'Shots', value: '8 - 5'),
              _StatItem(title: 'Possession', value: '56% - 44%'),
              _StatItem(title: 'Corners', value: '4 - 2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamInfo(String name) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.greenAccent,
          child: Icon(Icons.shield_rounded, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}