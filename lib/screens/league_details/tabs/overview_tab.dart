import 'package:flutter/material.dart';

import '../../../models/league_champion_model.dart';
import '../../../models/league_profile_model.dart';
import '../../../utils/league_history_data.dart';
import '../../../utils/league_profile_data.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> leagueInfo;

  const OverviewTab({
    super.key,
    required this.leagueInfo,
  });

  @override
  Widget build(BuildContext context) {
    final leagueId = leagueInfo['id'] as int? ?? 0;
    final profile = LeagueProfileData.byLeagueId(leagueId);
    final champions = LeagueHistoryData.championsFor(leagueId);
    final latestChampion = champions.isEmpty ? null : champions.first;
    final recordChampion = _recordChampion(champions);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heroSummary(profile, latestChampion),
        const SizedBox(height: 14),
        _factsGrid(profile),
        const SizedBox(height: 14),
        _infoCard(
          title: 'Competition Details',
          children: [
            _row('Competition', leagueInfo['name']),
            _row('Country / Region', leagueInfo['country']),
            _row('Current app season', leagueInfo['season']),
            _row('League ID', leagueInfo['id'].toString()),
          ],
        ),
        const SizedBox(height: 14),
        _infoCard(
          title: 'Champions Snapshot',
          children: [
            _row('Latest champion', latestChampion?.champion ?? 'Unknown'),
            _row('Latest season', latestChampion?.season ?? '-'),
            _row(
              'Most frequent in history tab',
              recordChampion == null
                  ? 'Unknown'
                  : '${recordChampion.name} (${recordChampion.count})',
            ),
            _row('History records', champions.length.toString()),
          ],
        ),
        const SizedBox(height: 14),
        _infoCard(
          title: 'About',
          children: [
            Text(
              profile?.about ??
                  'Detailed profile data is not available for this competition yet.',
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroSummary(
    LeagueProfileModel? profile,
    LeagueChampionModel? latestChampion,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff132015), Color(0xff111827)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
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
                  leagueInfo['name'] ?? 'League',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  latestChampion == null
                      ? profile?.type ?? 'Competition profile'
                      : 'Latest champion: ${latestChampion.champion}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _factsGrid(LeagueProfileModel? profile) {
    final facts = [
      _FactItem('Founded', profile?.founded ?? '-'),
      _FactItem('Type', profile?.type ?? '-'),
      _FactItem('Teams', profile?.teams ?? '-'),
      _FactItem('Format', profile?.format ?? '-'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: facts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        final fact = facts[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff161b22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fact.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                fact.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _RecordChampion? _recordChampion(List<LeagueChampionModel> champions) {
    if (champions.isEmpty) {
      return null;
    }

    final counts = <String, int>{};

    for (final champion in champions) {
      counts[champion.champion] = (counts[champion.champion] ?? 0) + 1;
    }

    var bestName = counts.keys.first;
    var bestCount = counts[bestName] ?? 0;

    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestName = entry.key;
        bestCount = entry.value;
      }
    }

    return _RecordChampion(bestName, bestCount);
  }
}

class _FactItem {
  final String label;
  final String value;

  const _FactItem(this.label, this.value);
}

class _RecordChampion {
  final String name;
  final int count;

  const _RecordChampion(this.name, this.count);
}
