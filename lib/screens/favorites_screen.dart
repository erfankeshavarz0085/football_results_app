import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/league_model.dart';
import '../models/player_profile_model.dart';
import '../providers/app_settings_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/team_logo.dart';
import 'league_details/league_details_screen.dart';
import 'match_details_screen.dart';
import 'player_details_screen.dart';
import 'team_details_screen.dart';

enum FavoriteFilter { all, matches, leagues, teams, players }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoriteFilter selectedFilter = FavoriteFilter.all;

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoriteTeams = favoriteProvider.favoriteTeams;
    final favoriteLeagues = favoriteProvider.favoriteLeagues;
    final followedMatches = favoriteProvider.followedMatches;
    final favoritePlayers = favoriteProvider.favoritePlayers;
    final hasFavorites =
        favoriteTeams.isNotEmpty ||
        favoriteLeagues.isNotEmpty ||
        followedMatches.isNotEmpty ||
        favoritePlayers.isNotEmpty;
    final showMatches =
        selectedFilter == FavoriteFilter.all ||
        selectedFilter == FavoriteFilter.matches;
    final showLeagues =
        selectedFilter == FavoriteFilter.all ||
        selectedFilter == FavoriteFilter.leagues;
    final showTeams =
        selectedFilter == FavoriteFilter.all ||
        selectedFilter == FavoriteFilter.teams;
    final showPlayers =
        selectedFilter == FavoriteFilter.all ||
        selectedFilter == FavoriteFilter.players;
    final hasFilteredFavorites =
        (showMatches && followedMatches.isNotEmpty) ||
        (showLeagues && favoriteLeagues.isNotEmpty) ||
        (showTeams && favoriteTeams.isNotEmpty) ||
        (showPlayers && favoritePlayers.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          !favoriteProvider.isLoaded
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
                    favoritePlayers.length,
                  ),
                  const SizedBox(height: 14),
                  _filterBar(
                    teamCount: favoriteTeams.length,
                    leagueCount: favoriteLeagues.length,
                    matchCount: followedMatches.length,
                    playerCount: favoritePlayers.length,
                  ),
                  const SizedBox(height: 20),
                  if (!hasFilteredFavorites)
                    _filteredEmptyState()
                  else ...[
                    if (showMatches && followedMatches.isNotEmpty) ...[
                      _sectionTitle('Followed Matches'),
                      const SizedBox(height: 12),
                      ...followedMatches.map((match) {
                        return _followedMatchCard(context, match);
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (showLeagues && favoriteLeagues.isNotEmpty) ...[
                      _sectionTitle('Favorite Leagues'),
                      const SizedBox(height: 12),
                      ...favoriteLeagues.map((league) {
                        return _favoriteLeagueCard(context, league);
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (showTeams && favoriteTeams.isNotEmpty) ...[
                      _sectionTitle('Favorite Teams'),
                      const SizedBox(height: 12),
                      ...favoriteTeams.map((team) {
                        return _favoriteTeamCard(context, team);
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (showPlayers && favoritePlayers.isNotEmpty) ...[
                      _sectionTitle('Favorite Players'),
                      const SizedBox(height: 12),
                      ...favoritePlayers.map((player) {
                        return _favoritePlayerCard(context, player);
                      }),
                    ],
                  ],
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
              'Open a player, team, league or match and save it for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    int teamCount,
    int leagueCount,
    int matchCount,
    int playerCount,
  ) {
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
              '$teamCount teams, $leagueCount leagues, $playerCount players and $matchCount matches saved.',
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

  Widget _filterBar({
    required int teamCount,
    required int leagueCount,
    required int matchCount,
    required int playerCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            FavoriteFilter.all,
            'All',
            teamCount + leagueCount + matchCount + playerCount,
          ),
          _filterChip(FavoriteFilter.matches, 'Matches', matchCount),
          _filterChip(FavoriteFilter.leagues, 'Leagues', leagueCount),
          _filterChip(FavoriteFilter.teams, 'Teams', teamCount),
          _filterChip(FavoriteFilter.players, 'Players', playerCount),
        ],
      ),
    );
  }

  Widget _filterChip(FavoriteFilter filter, String label, int count) {
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() => selectedFilter = filter);
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.greenAccent.withValues(alpha: 0.16)
                    : const Color(0xff161b22),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.greenAccent.withValues(alpha: 0.45)
                      : Colors.white10,
            ),
          ),
          child: Text(
            '$label $count',
            style: TextStyle(
              color: isSelected ? Colors.greenAccent : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filteredEmptyState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Text(
          'No items in this filter',
          style: TextStyle(color: Colors.grey),
        ),
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
                  icon: const Icon(Icons.star_rounded, color: Colors.amber),
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
            color:
                isActive
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
        TeamLogo(logoUrl: logo, size: 34),
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
            builder:
                (_) => LeagueDetailsScreen(
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
                errorWidget:
                    (_, __, ___) =>
                        Icon(league.fallbackIcon, color: Colors.black),
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
              icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
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
            builder:
                (_) => TeamDetailsScreen(
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
            TeamLogo(logoUrl: team.logo, size: 44),
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
              icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoritePlayerCard(BuildContext context, PlayerProfileModel player) {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerDetailsScreen(player: player),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xff161b22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xff0d1117),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  player.photo.isEmpty
                      ? const Icon(
                        Icons.person_rounded,
                        color: Colors.greenAccent,
                      )
                      : CachedNetworkImage(
                        imageUrl: player.photo,
                        fit: BoxFit.cover,
                        errorWidget:
                            (_, __, ___) => const Icon(
                              Icons.person_rounded,
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
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    [
                      player.nationality,
                      player.position,
                    ].where((value) => value.isNotEmpty).join(' - '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => favoriteProvider.removeFavoritePlayer(player.id),
              icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
