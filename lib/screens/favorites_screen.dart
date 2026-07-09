import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/league_model.dart';
import '../providers/favorite_provider.dart';
import 'league_details/league_details_screen.dart';
import 'team_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoriteTeams = favoriteProvider.favoriteTeams;
    final favoriteLeagues = favoriteProvider.favoriteLeagues;
    final hasFavorites = favoriteTeams.isNotEmpty || favoriteLeagues.isNotEmpty;

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
                    _header(favoriteTeams.length, favoriteLeagues.length),
                    const SizedBox(height: 20),
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
              'Open a team or league page and tap the heart to keep it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(int teamCount, int leagueCount) {
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
              '$teamCount teams and $leagueCount leagues saved for quick access.',
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
