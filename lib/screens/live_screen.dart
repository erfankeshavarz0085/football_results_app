import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fixture_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/fixture_provider.dart';
import '../providers/recent_view_provider.dart';
import 'match_details_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final List<int> importantLeagueIds = const [
    39,
    140,
    135,
    78,
    61,
    2,
    1,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<FixtureProvider>(context, listen: false).loadLiveFixtures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.greenAccent,
          onRefresh: provider.loadLiveFixtures,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _topHeader(
                liveCount: provider.liveFixtures.length,
                onRefresh: provider.loadLiveFixtures,
              ),
              const SizedBox(height: 22),
              _sectionHeader(),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  ),
                )
              else if (provider.errorMessage != null)
                _messageBox(provider.errorMessage!)
              else if (provider.liveFixtures.isEmpty)
                _messageBox('No live matches right now')
              else
                ..._buildLeagueCards(provider.liveFixtures),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topHeader({
    required int liveCount,
    required VoidCallback onRefresh,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff201313),
            Color(0xff111827),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.sports_soccer, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Matches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$liveCount live fixtures right now',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Live Fixtures',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'Grouped by league',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  List<Widget> _buildLeagueCards(List<FixtureModel> fixtures) {
    final Map<int, List<FixtureModel>> importantGroups = {};
    final List<FixtureModel> otherMatches = [];

    for (final fixture in fixtures) {
      if (importantLeagueIds.contains(fixture.leagueId)) {
        importantGroups.putIfAbsent(fixture.leagueId, () => []);
        importantGroups[fixture.leagueId]!.add(fixture);
      } else {
        otherMatches.add(fixture);
      }
    }

    final widgets = <Widget>[];

    final orderedImportantIds = importantLeagueIds
        .where((id) => importantGroups.containsKey(id))
        .toList();

    for (final leagueId in orderedImportantIds) {
      final matches = importantGroups[leagueId] ?? [];
      if (matches.isEmpty) continue;
      widgets.add(_leagueCard(matches.first, matches));
    }

    if (otherMatches.isNotEmpty) {
      widgets.add(_otherLiveCard(otherMatches));
    }

    return widgets;
  }

  Widget _leagueCard(FixtureModel firstMatch, List<FixtureModel> matches) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leagueCardHeader(
            leagueName: firstMatch.leagueName,
            country: _displayCountry(firstMatch),
            logo: firstMatch.leagueLogo,
            count: matches.length,
            isOther: false,
          ),
          const SizedBox(height: 12),
          ...matches.map(
            (match) => _liveMatchRow(match, showCompetitionInfo: false),
          ),
        ],
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

  Widget _otherLiveCard(List<FixtureModel> matches) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leagueCardHeader(
            leagueName: 'Other Live Matches',
            country: 'Various competitions',
            logo: '',
            count: matches.length,
            isOther: true,
          ),
          const SizedBox(height: 12),
          ...matches.map(
            (match) => _liveMatchRow(match, showCompetitionInfo: true),
          ),
        ],
      ),
    );
  }

  Widget _leagueCardHeader({
    required String leagueName,
    required String country,
    required String logo,
    required int count,
    required bool isOther,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xff0d1117),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: logo.isNotEmpty && !isOther
              ? CachedNetworkImage(
                  imageUrl: logo,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.greenAccent,
                  ),
                )
              : Icon(
                  isOther ? Icons.public_rounded : Icons.emoji_events_rounded,
                  color: Colors.greenAccent,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leagueName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                country,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '$count live',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _liveMatchRow(
    FixtureModel fixture, {
    required bool showCompetitionInfo,
  }) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFollowed = favoriteProvider.isFollowedMatch(fixture.id);
    final homeScore = fixture.homeScore?.toString() ?? '-';
    final awayScore = fixture.awayScore?.toString() ?? '-';

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
        color: const Color(0xff0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          if (showCompetitionInfo) ...[
            Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.greenAccent,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_displayCountry(fixture)} • ${fixture.leagueName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => favoriteProvider.toggleFollowedMatch(fixture),
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
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(child: _teamMini(fixture.homeTeam, fixture.homeLogo)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      '$homeScore - $awayScore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatLiveStatus(fixture.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _teamMini(fixture.awayTeam, fixture.awayLogo)),
              if (!showCompetitionInfo)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => favoriteProvider.toggleFollowedMatch(fixture),
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
          if (fixture.round.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _cleanRound(fixture.round),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ],
      ),
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

  Widget _messageBox(String text) {
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

  String _formatLiveStatus(String status) {
    switch (status) {
      case '1H':
        return 'LIVE 1H';
      case '2H':
        return 'LIVE 2H';
      case 'HT':
        return 'HALF TIME';
      case 'ET':
        return 'EXTRA TIME';
      case 'P':
        return 'PENALTIES';
      case 'BT':
        return 'BREAK';
      default:
        return status.isEmpty ? 'LIVE' : status;
    }
  }

  String _displayCountry(FixtureModel fixture) {
    if (fixture.leagueId == 2) return 'Europe';
    if (fixture.leagueId == 1) return 'International';
    if (fixture.country.toLowerCase() == 'world') return 'International';
    return fixture.country.isEmpty ? 'Unknown' : fixture.country;
  }

  String _cleanRound(String round) {
    return round
        .replaceAll('Regular Season - ', 'Matchweek ')
        .replaceAll('Qualification - ', 'Qualification • ')
        .replaceAll('League Stage - ', 'League Stage • ');
  }
}
