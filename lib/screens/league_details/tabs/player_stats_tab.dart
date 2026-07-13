import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/player_leader_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/error_messages.dart';

class PlayerStatsTab extends StatefulWidget {
  final int leagueId;
  final int season;

  const PlayerStatsTab({
    super.key,
    required this.leagueId,
    required this.season,
  });

  @override
  State<PlayerStatsTab> createState() => _PlayerStatsTabState();
}

class _PlayerStatsTabState extends State<PlayerStatsTab> {
  late Future<LeaguePlayerLeaders> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ApiService().getLeaguePlayerLeaders(
      widget.leagueId,
      widget.season,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LeaguePlayerLeaders>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }
        if (snapshot.hasError) {
          return _error(ErrorMessages.fromException(snapshot.error!));
        }
        final data = snapshot.data!;
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const Material(
                color: Color(0xff111827),
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.greenAccent,
                  labelColor: Colors.greenAccent,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Goals'),
                    Tab(text: 'Assists'),
                    Tab(text: 'Clean sheets'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _leaderList(data.scorers, 'goals'),
                    _leaderList(data.assists, 'assists'),
                    _leaderList(data.cleanSheets, 'clean sheets'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _leaderList(List<PlayerLeaderModel> players, String label) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          'No $label data is available for this season.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final player = players[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff161b22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _photo(player.playerPhoto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.playerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      player.teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${player.value}',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _photo(String url) {
    return ClipOval(
      child: Container(
        width: 46,
        height: 46,
        color: Colors.white10,
        child:
            url.isEmpty
                ? const Icon(Icons.person_rounded, color: Colors.greenAccent)
                : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget:
                      (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: Colors.greenAccent,
                      ),
                ),
      ),
    );
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => setState(_load),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
