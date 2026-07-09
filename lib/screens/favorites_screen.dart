import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/league_model.dart';
import '../providers/app_settings_provider.dart';
import '../providers/favorite_provider.dart';
import 'league_details/league_details_screen.dart';
import 'match_details_screen.dart';
import 'team_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoriteTeams = favoriteProvider.favoriteTeams;
    final favoriteLeagues = favoriteProvider.favoriteLeagues;
    final followedMatches = favoriteProvider.followedMatches;
    final hasFavorites = favoriteTeams.isNotEmpty ||
        favoriteLeagues.isNotEmpty ||
        followedMatches.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: !favoriteProvider.isLoaded
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : !hasFavorites
              ? _emptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _header(
                      favoriteTeams.length,
                      favoriteLeagues.length,
                      followedMatches.length,
                    ),
                    const SizedBox(height: 20),
                    if (followedMatches.isNotEmpty) ...[
                      _sectionTitle('Followed Matches'),
                      const SizedBox(height: 12),
                      ...followedMatches.map((match) {
                        return _followedMatchCard(context, match);
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (favoriteLeagues.isNotEmpty) ...[
                      _sectionTitle('Favorite Leagues'),
                      const SizedBox(height: 12),
                      ...favoriteLeagues.map((league) {
                        return _favoriteLeagueCard(context, league);
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (favoriteTeams.isNotEmpty) ...[
                      _sectionTitle('Favorite Teams'),
                      const SizedBox(height: 12),
                    ],
                    ...favoriteTeams.map((team) {
                      return _favoriteTeamCard(context, team);
                    }),
                  ],
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.greenAccent,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No favorites yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open a team, league or match card and save it for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(int teamCount, int leagueCount, int matchCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.favorite, color: Colors.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$teamCount teams, $leagueCount leagues and $matchCount matches saved for quick access.',
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _followedMatchCard(BuildContext context, FollowedMatchModel match) {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    final settings = Provider.of<AppSettingsProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailsScreen(fixtureId: match.fixtureId),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    favoriteProvider.removeFollowedMatch(match.fixtureId);
                  },
                  icon: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _matchTeam(match.homeTeam, match.homeLogo)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        _matchScore(match),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.status.isEmpty ? 'Fixture' : match.status,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _matchTeam(match.awayTeam, match.awayLogo)),
              ],
            ),
            if (settings.showMatchAlertControls) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  _alertChip(
                    label: 'Kickoff',
                    isActive: match.kickoffAlert,
                    onTap: () {
                      favoriteProvider.updateMatchAlert(
                        fixtureId: match.fixtureId,
                        kickoffAlert: !match.kickoffAlert,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _alertChip(
                    label: 'Goals',
                    isActive: match.goalAlert,
                    onTap: () {
                      favoriteProvider.updateMatchAlert(
                        fixtureId: match.fixtureId,
                        goalAlert: !match.goalAlert,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _alertChip(
                    label: 'Full time',
                    isActive: match.fullTimeAlert,
                    onTap: () {
                      favoriteProvider.updateMatchAlert(
                        fixtureId: match.fixtureId,
                        fullTimeAlert: !match.fullTimeAlert,
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _alertChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.greenAccent.withValues(alpha: 0.16)
                : const Color(0xff0d1117),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? Colors.greenAccent : Colors.white10,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: isActive ? Colors.greenAccent : Colors.grey,
                size: 14,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.greenAccent : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _matchTeam(String name, String logo) {
    return Column(
      children: [
        if (logo.isEmpty)
          const Icon(
            Icons.shield_rounded,
            color: Colors.greenAccent,
            size: 28,
          )
        else
          CachedNetworkImage(
            imageUrl: logo,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => const Icon(
              Icons.shield_rounded,
              color: Colors.greenAccent,
              size: 28,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  String _matchScore(FollowedMatchModel match) {
    if (match.homeScore == null || match.awayScore == null) {
      return '-';
    }

    return '${match.homeScore} - ${match.awayScore}';
  }

  Widget _favoriteLeagueCard(BuildContext context, LeagueModel league) {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeagueDetailsScreen(
              leagueId: league.id,
              leagueName: league.name,
            ),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: CachedNetworkImage(
                imageUrl: league.logoUrl,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => Icon(
                  league.fallbackIcon,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    league.country,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => favoriteProvider.removeFavoriteLeague(league.id),
              icon: const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteTeamCard(BuildContext context, FavoriteTeamModel team) {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDetailsScreen(
              teamId: team.id,
              fallbackName: team.name,
              fallbackLogo: team.logo,
            ),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xff0d1117),
                borderRadius: BorderRadius.circular(14),
              ),
              child: team.logo.isEmpty
                  ? const Icon(
                      Icons.shield_rounded,
                      color: Colors.greenAccent,
                    )
                  : CachedNetworkImage(
                      imageUrl: team.logo,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.shield_rounded,
                        color: Colors.greenAccent,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    team.country.isEmpty ? 'Unknown country' : team.country,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => favoriteProvider.removeFavoriteTeam(team.id),
              icon: const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
