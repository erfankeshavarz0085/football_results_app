import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fixture_model.dart';
import '../providers/favorite_provider.dart';
import '../services/api_service.dart';
import 'match_details_screen.dart';

class WorldCupScreen extends StatefulWidget {
  const WorldCupScreen({super.key});

  @override
  State<WorldCupScreen> createState() => _WorldCupScreenState();
}

class _WorldCupScreenState extends State<WorldCupScreen> {
  late Future<List<FixtureModel>> worldCupFixtures;

  @override
  void initState() {
    super.initState();
    worldCupFixtures = ApiService().getWorldCupFixtures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'World Cup 2022',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<FixtureModel>>(
        future: worldCupFixtures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'خطا در دریافت اطلاعات جام جهانی',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return const Center(
              child: Text(
                'اطلاعاتی برای جام جهانی 2022 پیدا نشد',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(),
              const SizedBox(height: 20),
              ...matches.map((match) => _matchCard(match)),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.public, color: Colors.black),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'FIFA World Cup 2022 matches, results and schedule.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchCard(FixtureModel match) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFollowed = favoriteProvider.isFollowedMatch(match.id);
    final homeScore = match.homeScore?.toString() ?? '-';
    final awayScore = match.awayScore?.toString() ?? '-';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailsScreen(fixtureId: match.id),
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.leagueName,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Text(
                  match.status,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => favoriteProvider.toggleFollowedMatch(match),
                  icon: Icon(
                    isFollowed
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isFollowed ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _team(match.homeTeam)),
                Text(
                  '$homeScore - $awayScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(child: _team(match.awayTeam)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _team(String name) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.greenAccent,
          child: Icon(Icons.flag, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
