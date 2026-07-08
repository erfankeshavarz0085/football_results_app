import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_detail_model.dart';
import '../providers/match_detail_provider.dart';

class MatchDetailsScreen extends StatefulWidget {
  final int fixtureId;

  const MatchDetailsScreen({
    super.key,
    required this.fixtureId,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      Provider.of<MatchDetailProvider>(
        context,
        listen: false,
      ).loadMatchDetails(widget.fixtureId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MatchDetailProvider>(context);
    final match = provider.matchDetail;

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        backgroundColor: const Color(0xff0d1117),
        title: const Text('Match Details'),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : provider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              : match == null
                  ? const Center(
                      child: Text(
                        'No match data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _matchBody(match),
    );
  }

  Widget _matchBody(MatchDetailModel match) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _scoreCard(match),
          const SizedBox(height: 20),
          _infoCard(
            Icons.stadium,
            'Venue',
            '${match.venue} ${match.city}'.trim().isEmpty
                ? 'Unknown'
                : '${match.venue} ${match.city}'.trim(),
          ),
          _infoCard(
            Icons.person,
            'Referee',
            match.referee.isEmpty ? 'Unknown' : match.referee,
          ),
          _eventsCard(match.events),
          _statisticsCard(match.statistics),
          _lineupsCard(match.lineups),
        ],
      ),
    );
  }

  Widget _scoreCard(MatchDetailModel match) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _team(match.homeTeam, match.homeLogo),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  '${match.homeScore ?? "-"} - ${match.awayScore ?? "-"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  match.status,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _team(match.awayTeam, match.awayLogo),
        ],
      ),
    );
  }

  Widget _eventsCard(List<MatchEventModel> events) {
    return _sectionCard(
      title: 'Events',
      icon: Icons.timeline_rounded,
      emptyText: 'No events available',
      isEmpty: events.isEmpty,
      children: events.map((event) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                child: Text(
                  event.minute,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                _eventIcon(event.type, event.detail),
                color: _eventColor(event.type),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.playerName.isEmpty ? event.teamName : event.playerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _eventSubtitle(event),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _statisticsCard(List<MatchStatisticModel> statistics) {
    if (statistics.length < 2) {
      return _sectionCard(
        title: 'Statistics',
        icon: Icons.bar_chart_rounded,
        emptyText: 'No statistics available',
        isEmpty: true,
        children: const [],
      );
    }

    final homeStats = statistics[0];
    final awayStats = statistics[1];
    final rows = <Widget>[];

    for (final homeItem in homeStats.items) {
      StatisticItemModel? awayItem;

      for (final item in awayStats.items) {
        if (item.type == homeItem.type) {
          awayItem = item;
          break;
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  homeItem.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  homeItem.type,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  awayItem?.value ?? '-',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _sectionCard(
      title: 'Statistics',
      icon: Icons.bar_chart_rounded,
      emptyText: 'No statistics available',
      isEmpty: false,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(child: _miniTeamHeader(homeStats.teamName, homeStats.teamLogo)),
              Expanded(
                child: _miniTeamHeader(awayStats.teamName, awayStats.teamLogo),
              ),
            ],
          ),
        ),
        ...rows,
      ],
    );
  }

  Widget _lineupsCard(List<MatchLineupModel> lineups) {
    return _sectionCard(
      title: 'Lineups',
      icon: Icons.groups_rounded,
      emptyText: 'No lineups available',
      isEmpty: lineups.isEmpty,
      children: lineups.map((lineup) => _lineupBlock(lineup)).toList(),
    );
  }

  Widget _lineupBlock(MatchLineupModel lineup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff0d1117),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _logo(lineup.teamLogo, 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lineup.teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                lineup.formation.isEmpty ? '-' : lineup.formation,
                style: const TextStyle(color: Colors.greenAccent),
              ),
            ],
          ),
          if (lineup.coachName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Coach: ${lineup.coachName}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          _playersList('Starting XI', lineup.startXI.take(11).toList()),
          if (lineup.substitutes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _playersList('Substitutes', lineup.substitutes.take(8).toList()),
          ],
        ],
      ),
    );
  }

  Widget _playersList(String title, List<LineupPlayerModel> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        ...players.map((player) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    player.number?.toString() ?? '-',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                  player.position,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required String emptyText,
    required bool isEmpty,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.greenAccent),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isEmpty)
            Text(emptyText, style: const TextStyle(color: Colors.grey))
          else
            ...children,
        ],
      ),
    );
  }

  Widget _team(String name, String logo) {
    return Expanded(
      child: Column(
        children: [
          _logo(logo, 55),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTeamHeader(String name, String logo) {
    return Row(
      children: [
        _logo(logo, 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _logo(String logo, double size) {
    if (logo.isEmpty) {
      return Icon(
        Icons.shield,
        color: Colors.greenAccent,
        size: size,
      );
    }

    return CachedNetworkImage(
      imageUrl: logo,
      width: size,
      height: size,
      errorWidget: (_, __, ___) {
        return Icon(
          Icons.shield,
          color: Colors.greenAccent,
          size: size,
        );
      },
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _eventIcon(String type, String detail) {
    if (type == 'Goal') return Icons.sports_soccer;
    if (type == 'Card') return Icons.style_rounded;
    if (type == 'subst') return Icons.swap_horiz_rounded;
    if (detail.toLowerCase().contains('penalty')) return Icons.adjust_rounded;
    return Icons.circle;
  }

  Color _eventColor(String type) {
    if (type == 'Goal') return Colors.greenAccent;
    if (type == 'Card') return Colors.amber;
    if (type == 'subst') return Colors.lightBlueAccent;
    return Colors.grey;
  }

  String _eventSubtitle(MatchEventModel event) {
    final parts = <String>[
      if (event.teamName.isNotEmpty) event.teamName,
      if (event.detail.isNotEmpty) event.detail,
      if (event.assistName.isNotEmpty) 'Assist: ${event.assistName}',
      if (event.comments.isNotEmpty) event.comments,
    ];

    return parts.join(' • ');
  }
}
