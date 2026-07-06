import 'package:flutter/material.dart';
import '../models/fixture_model.dart';
import '../services/api_service.dart';

class LeagueDetailsScreen extends StatefulWidget {
  final int leagueId;
  final String leagueName;

  const LeagueDetailsScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  State<LeagueDetailsScreen> createState() => _LeagueDetailsScreenState();
}

class _LeagueDetailsScreenState extends State<LeagueDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ApiService _apiService = ApiService();

  late Future<List<FixtureModel>> fixturesFuture;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    fixturesFuture = _apiService.getLeagueFixtures(widget.leagueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: Text(widget.leagueName),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.greenAccent,
          tabs: const [
            Tab(text: "Matches"),
            Tab(text: "Live"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------------- MATCHES ----------------
          FutureBuilder<List<FixtureModel>>(
            future: fixturesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error loading matches",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    "No matches found",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final match = data[index];

                  return _matchCard(match);
                },
              );
            },
          ),

          // ---------------- LIVE ----------------
          FutureBuilder<List<FixtureModel>>(
            future: _apiService.getLiveFixtures(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                );
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    "No live matches",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final match = data[index];

                  return _matchCard(match);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _matchCard(FixtureModel match) {
    final home = match.homeScore?.toString() ?? "-";
    final away = match.awayScore?.toString() ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  match.homeTeam,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Text(
                "$home - $away",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  match.awayTeam,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            match.status,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}