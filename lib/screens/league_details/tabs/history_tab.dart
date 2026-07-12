import 'package:flutter/material.dart';

import '../../../models/league_champion_model.dart';
import '../../../services/api_service.dart';

class HistoryTab extends StatefulWidget {
  final int leagueId;
  final String leagueName;
  final List<int> seasons;

  const HistoryTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.seasons,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String? selectedSeason;
  late Future<List<LeagueChampionModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService().getLeagueChampions(
      widget.leagueId,
      widget.seasons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeagueChampionModel>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }
        if (snapshot.hasError) {
          return _errorState();
        }
        return _historyContent(snapshot.data ?? const []);
      },
    );
  }

  Widget _historyContent(List<LeagueChampionModel> champions) {
    if (champions.isEmpty) {
      return _emptyState();
    }

    final filteredChampions =
        selectedSeason == null
            ? champions
            : champions.where((item) => item.season == selectedSeason).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _summaryCard(champions),
        const SizedBox(height: 14),
        _seasonPicker(champions),
        const SizedBox(height: 14),
        ...filteredChampions.map(_championCard),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: FilledButton.icon(
        onPressed: () {
          setState(() {
            _historyFuture = ApiService().getLeagueChampions(
              widget.leagueId,
              widget.seasons,
            );
          });
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry history'),
      ),
    );
  }

  Widget _summaryCard(List<LeagueChampionModel> champions) {
    final mostRecent = champions.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.leagueName} Champions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Latest: ${mostRecent.champion} (${mostRecent.season})',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          _countBadge(champions.length),
        ],
      ),
    );
  }

  Widget _seasonPicker(List<LeagueChampionModel> champions) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: Colors.greenAccent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Select season',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedSeason,
              dropdownColor: const Color(0xff161b22),
              iconEnabledColor: Colors.greenAccent,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All seasons'),
                ),
                ...champions.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.season,
                    child: Text(item.season),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSeason = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _championCard(LeagueChampionModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _seasonBadge(item.season),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.champion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _subtitle(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _seasonBadge(String season) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff0d1117),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        season,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No standings-based champion history is available for this competition.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _subtitle(LeagueChampionModel item) {
    final parts = <String>[];

    if (item.runnerUp.isNotEmpty) {
      parts.add('Runner-up: ${item.runnerUp}');
    }

    if (item.note.isNotEmpty) {
      parts.add(item.note);
    }

    if (parts.isEmpty) {
      return 'League winner';
    }

    return parts.join(' - ');
  }
}
