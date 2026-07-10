import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/standing_model.dart';
import '../../../providers/fixture_provider.dart';
import '../../../widgets/empty_state_card.dart';
import '../../../widgets/team_logo.dart';
import '../../team_details_screen.dart';

class StandingsTab extends StatefulWidget {
  final int leagueId;
  final String leagueName;
  final int season;

  const StandingsTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.season,
  });

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  String? selectedWorldCupGroup;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      Provider.of<FixtureProvider>(
        context,
        listen: false,
      ).loadLeagueStandings(
        widget.leagueId,
        season: widget.season,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final standings = provider.getStandingsForLeague(
      widget.leagueId,
      season: widget.season,
    );

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (provider.isStandingsLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                ),
              )
            else if (provider.standingsErrorMessage != null)
              Expanded(
                child: _standingsError(provider.standingsErrorMessage!),
              )
            else if (standings.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    widget.leagueId == 1
                        ? 'World Cup standings may appear after the group stage starts'
                        : 'No standings available',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Expanded(child: _standingsList(context, standings)),
          ],
        ),
      ),
    );
  }

  Widget _standingsList(BuildContext context, List<StandingModel> standings) {
    if (widget.leagueId != 1) {
      return ListView.builder(
        itemCount: standings.length,
        itemBuilder: (context, index) {
          return _standingCard(context, standings[index]);
        },
      );
    }

    final groupedStandings = _groupWorldCupStandings(standings);
    final groups = groupedStandings.keys.toList();

    if (groups.isEmpty) {
      return const Center(
        child: Text(
          'No standings available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (selectedWorldCupGroup == null ||
        !groupedStandings.containsKey(selectedWorldCupGroup)) {
      selectedWorldCupGroup = groups.first;
    }

    final currentGroup = selectedWorldCupGroup!;
    final groupTeams = groupedStandings[currentGroup] ?? const <StandingModel>[];

    return ListView(
      children: [
        _groupSelector(currentGroup: currentGroup, groups: groups),
        const SizedBox(height: 12),
        ...groupTeams.take(4).map((team) => _standingCard(context, team)),
      ],
    );
  }

  Widget _standingsError(String message) {
    final provider = Provider.of<FixtureProvider>(context, listen: false);

    return Center(
      child: EmptyStateCard(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load standings',
        message: message,
        accentColor: Colors.redAccent,
        actionLabel: 'Retry',
        onAction: () {
          provider.loadLeagueStandings(
            widget.leagueId,
            season: widget.season,
          );
        },
      ),
    );
  }

  Map<String, List<StandingModel>> _groupWorldCupStandings(
    List<StandingModel> standings,
  ) {
    final grouped = <String, List<StandingModel>>{};

    for (final team in standings) {
      final group = team.group.trim().isEmpty ? 'World Cup' : team.group.trim();

      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(team);
    }

    for (final teams in grouped.values) {
      teams.sort((a, b) => a.rank.compareTo(b.rank));
    }

    return Map.fromEntries(
      grouped.entries.toList()
        ..sort(
          (a, b) => _groupSortValue(a.key).compareTo(_groupSortValue(b.key)),
        ),
    );
  }

  int _groupSortValue(String group) {
    final match = RegExp(r'Group ([A-H])').firstMatch(group);

    if (match == null) {
      return 1000 + group.hashCode.abs();
    }

    return match.group(1)!.codeUnitAt(0);
  }

  Widget _groupSelector({
    required String currentGroup,
    required List<String> groups,
  }) {
    return InkWell(
      onTap: () => _showGroupPicker(groups),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.table_chart_rounded,
              color: Colors.greenAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                currentGroup,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupPicker(List<String> groups) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0d1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Choose Group',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...groups.map((group) {
                final isSelected = group == selectedWorldCupGroup;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.greenAccent.withValues(alpha: 0.12)
                        : const Color(0xff161b22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.greenAccent.withValues(alpha: 0.35)
                          : Colors.white10,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      group,
                      style: TextStyle(
                        color: isSelected ? Colors.greenAccent : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.greenAccent,
                          )
                        : null,
                    onTap: () {
                      setState(() => selectedWorldCupGroup = group);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _standingCard(BuildContext context, StandingModel team) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDetailsScreen(
              teamId: team.teamId,
              fallbackName: team.teamName,
              fallbackLogo: team.teamLogo,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${team.rank}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TeamLogo(logoUrl: team.teamLogo, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    team.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xff0d1117),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('P', team.played),
                  _statItem('W', team.win),
                  _statItem('D', team.draw),
                  _statItem('L', team.lose),
                  _statItem('GF', team.goalsFor),
                  _statItem('GA', team.goalsAgainst),
                  _statItem('GD', team.goalDifference),
                  Column(
                    children: [
                      const Text(
                        'PTS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${team.points}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String title, int value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
