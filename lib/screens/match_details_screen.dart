import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_detail_model.dart';
import '../providers/match_detail_provider.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/team_logo.dart';
import 'team_details_screen.dart';

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
              ? _errorState(provider.errorMessage!)
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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _scoreCard(match),
          ),
          const TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Stats'),
              Tab(text: 'Lineups'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _summaryTab(match),
                _statsTab(match.statistics),
                _lineupsTab(match.lineups),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message) {
    final provider = Provider.of<MatchDetailProvider>(context, listen: false);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: EmptyStateCard(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load match details',
          message: message,
          accentColor: Colors.redAccent,
          actionLabel: 'Retry',
          onAction: () => provider.loadMatchDetails(widget.fixtureId),
        ),
      ),
    );
  }

  Widget _summaryTab(MatchDetailModel match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _matchInfoGrid(match),
        const SizedBox(height: 12),
        _eventsCard(match.events),
      ],
    );
  }

  Widget _statsTab(List<MatchStatisticModel> statistics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statisticsCard(statistics),
      ],
    );
  }

  Widget _lineupsTab(List<MatchLineupModel> lineups) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _lineupsCard(lineups),
      ],
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
          _team(match.homeTeamId, match.homeTeam, match.homeLogo),
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
          _team(match.awayTeamId, match.awayTeam, match.awayLogo),
        ],
      ),
    );
  }

  Widget _eventsCard(List<MatchEventModel> events) {
    final sortedEvents = [...events]..sort((a, b) {
        final minuteComparison = a.elapsed.compareTo(b.elapsed);

        if (minuteComparison != 0) {
          return minuteComparison;
        }

        return (a.extra ?? 0).compareTo(b.extra ?? 0);
      });

    return _sectionCard(
      title: 'Events',
      icon: Icons.timeline_rounded,
      emptyText: 'No events available',
      isEmpty: sortedEvents.isEmpty,
      children: sortedEvents.map((event) {
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

  Widget _matchInfoGrid(MatchDetailModel match) {
    final venue = '${match.venue} ${match.city}'.trim();

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.45,
      ),
      children: [
        _matchInfoTile(
          Icons.stadium_rounded,
          'Venue',
          venue.isEmpty ? 'Unknown' : venue,
        ),
        _matchInfoTile(
          Icons.person_rounded,
          'Referee',
          match.referee.isEmpty ? 'Unknown' : match.referee,
        ),
        _matchInfoTile(
          Icons.sports_soccer_rounded,
          'Events',
          match.events.length.toString(),
        ),
        _matchInfoTile(
          Icons.groups_rounded,
          'Lineups',
          match.lineups.length.toString(),
        ),
      ],
    );
  }

  Widget _matchInfoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _team(int teamId, String name, String logo) {
    return Expanded(
      child: InkWell(
        onTap: teamId == 0
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamDetailsScreen(
                      teamId: teamId,
                      fallbackName: name,
                      fallbackLogo: logo,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(14),
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
    return TeamLogo(logoUrl: logo, size: size);
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

    return parts.join(' - ');
  }
}
