import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/fixture_model.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/recent_view_provider.dart';
import '../../../services/api_service.dart';
import '../../../utils/error_messages.dart';
import '../../match_details_screen.dart';

class FixturesTab extends StatefulWidget {
  final int leagueId;
  final String leagueName;
  final int season;

  const FixturesTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.season,
  });

  @override
  State<FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends State<FixturesTab> {
  late Future<List<FixtureModel>> fixturesFuture;
  String? selectedRound;

  @override
  void initState() {
    super.initState();
    fixturesFuture = ApiService().getLeagueFixtures(
      widget.leagueId,
      season: widget.season,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FixtureModel>>(
      future: fixturesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        if (snapshot.hasError) {
          return _messageBox(ErrorMessages.fromException(snapshot.error!));
        }

        final fixtures = snapshot.data ?? [];

        if (fixtures.isEmpty) {
          return _messageBox('مسابقه‌ای برای این لیگ پیدا نشد');
        }

        final groupedFixtures = _groupFixturesByRound(fixtures);
        final rounds = groupedFixtures.keys.toList();

        selectedRound ??= rounds.isNotEmpty ? rounds.first : null;

        final currentRound = selectedRound ?? rounds.first;
        final currentFixtures = groupedFixtures[currentRound] ?? [];

        return RefreshIndicator(
          color: Colors.greenAccent,
          onRefresh: () async {
            setState(() {
              selectedRound = null;
              fixturesFuture = ApiService().getLeagueFixtures(
                widget.leagueId,
                season: widget.season,
              );
            });
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _roundSelector(
                currentRound: currentRound,
                rounds: rounds,
              ),
              const SizedBox(height: 14),
              _roundSummary(currentRound, currentFixtures.length),
              const SizedBox(height: 12),
              if (currentFixtures.isEmpty)
                _inlineMessage('No fixtures found for this round')
              else
                ...currentFixtures.map((fixture) => _fixtureCard(fixture)),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<FixtureModel>> _groupFixturesByRound(
    List<FixtureModel> fixtures,
  ) {
    final Map<String, List<FixtureModel>> grouped = {};

    for (final fixture in fixtures) {
      final round = fixture.round.isEmpty
          ? 'Fixtures'
          : _cleanRound(fixture.round);

      grouped.putIfAbsent(round, () => []);
      grouped[round]!.add(fixture);
    }

    return grouped;
  }

  Widget _roundSelector({
    required String currentRound,
    required List<String> rounds,
  }) {
    return InkWell(
      onTap: () => _showRoundPicker(rounds),
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
              Icons.calendar_month_rounded,
              color: Colors.greenAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Round',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentRound,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

  void _showRoundPicker(List<String> rounds) {
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
                'Choose Round',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...rounds.map((round) {
                final isSelected = round == selectedRound;

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
                      round,
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
                      setState(() {
                        selectedRound = round;
                      });
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

  Widget _roundSummary(String roundName, int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sports_soccer,
            color: Colors.greenAccent,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              roundName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$count fixtures',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _fixtureCard(FixtureModel fixture) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFollowed = favoriteProvider.isFollowedMatch(fixture.id);

    return InkWell(
      onTap: () {
        Provider.of<RecentViewProvider>(
          context,
          listen: false,
        ).addMatch(fixture);
        _openMatchDetails(fixture.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: _teamMini(fixture.homeTeam, fixture.homeLogo)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Text(
                  _scoreOrTime(fixture),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatStatus(fixture.status),
                  style: TextStyle(
                    color: _statusColor(fixture.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(fixture.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _teamMini(fixture.awayTeam, fixture.awayLogo)),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => favoriteProvider.toggleFollowedMatch(fixture),
            icon: Icon(
              isFollowed ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFollowed ? Colors.amber : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _openMatchDetails(int fixtureId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailsScreen(fixtureId: fixtureId),
      ),
    );
  }

  Widget _teamMini(String name, String logo) {
    return Column(
      children: [
        if (logo.isNotEmpty)
          CachedNetworkImage(
            imageUrl: logo,
            width: 34,
            height: 34,
            errorWidget: (_, __, ___) => const Icon(
              Icons.shield_rounded,
              color: Colors.greenAccent,
              size: 28,
            ),
          )
        else
          const Icon(
            Icons.shield_rounded,
            color: Colors.greenAccent,
            size: 28,
          ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }

  String _scoreOrTime(FixtureModel fixture) {
    if (fixture.status == 'NS') {
      return _formatTime(fixture.date);
    }

    final homeScore = fixture.homeScore?.toString() ?? '-';
    final awayScore = fixture.awayScore?.toString() ?? '-';

    return '$homeScore - $awayScore';
  }

  String _formatTime(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('HH:mm').format(parsedDate);
    } catch (_) {
      return '-';
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('d MMM yyyy').format(parsedDate);
    } catch (_) {
      return '';
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'NS':
        return 'Not Started';
      case 'FT':
        return 'Full Time';
      case 'HT':
        return 'Half Time';
      case '1H':
      case '2H':
        return 'Live';
      case 'PST':
        return 'Postponed';
      case 'CANC':
        return 'Canceled';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    if (status == '1H' || status == '2H') {
      return Colors.redAccent;
    }

    if (status == 'NS') {
      return Colors.greenAccent;
    }

    if (status == 'FT') {
      return Colors.grey;
    }

    return Colors.greenAccent;
  }

  String _cleanRound(String round) {
    return round
        .replaceAll('Regular Season - ', 'Matchweek ')
        .replaceAll('Qualification - ', 'Qualification • ')
        .replaceAll('League Stage - ', 'League Stage • ');
  }

  Widget _inlineMessage(String text) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _messageBox(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
