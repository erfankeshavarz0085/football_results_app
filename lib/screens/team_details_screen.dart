import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fixture_model.dart';
import '../models/team_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/team_provider.dart';
import 'match_details_screen.dart';

class TeamDetailsScreen extends StatefulWidget {
  final int teamId;
  final String fallbackName;
  final String fallbackLogo;

  const TeamDetailsScreen({
    super.key,
    required this.teamId,
    required this.fallbackName,
    this.fallbackLogo = '',
  });

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).loadTeamDetails(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeamProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text('Team Details'),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : provider.errorMessage != null
              ? _error(provider.errorMessage!)
              : provider.teamDetails == null
                  ? const Center(
                      child: Text(
                        'No team data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _body(provider.teamDetails!),
    );
  }

  Widget _body(TeamDetailsModel details) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(details.team, details.form),
        const SizedBox(height: 14),
        _infoCards(details.team),
        const SizedBox(height: 14),
        _recentFixtures(details.recentFixtures),
      ],
    );
  }

  Widget _header(TeamModel team, List<String> form) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(team.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff132015), Color(0xff111827)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _teamLogo(team.logo.isEmpty ? widget.fallbackLogo : team.logo, 66),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name.isEmpty ? widget.fallbackName : team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      team.country.isEmpty ? 'Unknown country' : team.country,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => favoriteProvider.toggleFavorite(team.id),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            ],
          ),
          if (form.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Recent form',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                ...form.map(_formDot),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCards(TeamModel team) {
    return Column(
      children: [
        _infoCard(
          Icons.calendar_month_rounded,
          'Founded',
          team.founded == 0 ? 'Unknown' : team.founded.toString(),
        ),
        _infoCard(
          Icons.stadium_rounded,
          'Venue',
          team.venueName.isEmpty ? 'Unknown' : team.venueName,
        ),
        _infoCard(
          Icons.location_city_rounded,
          'City',
          team.venueCity.isEmpty ? 'Unknown' : team.venueCity,
        ),
      ],
    );
  }

  Widget _recentFixtures(List<FixtureModel> fixtures) {
    return _sectionCard(
      title: 'Recent Matches',
      icon: Icons.history_rounded,
      emptyText: 'No recent matches available',
      isEmpty: fixtures.isEmpty,
      children: fixtures.map(_fixtureRow).toList(),
    );
  }

  Widget _fixtureRow(FixtureModel fixture) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailsScreen(fixtureId: fixture.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xff0d1117),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fixture.homeTeam,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${fixture.homeScore ?? "-"} - ${fixture.awayScore ?? "-"}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                fixture.awayTeam,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
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

  Widget _teamLogo(String logo, double size) {
    if (logo.isEmpty) {
      return Icon(
        Icons.shield_rounded,
        color: Colors.greenAccent,
        size: size,
      );
    }

    return CachedNetworkImage(
      imageUrl: logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorWidget: (_, __, ___) {
        return Icon(
          Icons.shield_rounded,
          color: Colors.greenAccent,
          size: size,
        );
      },
    );
  }

  Widget _formDot(String value) {
    final color = switch (value) {
      'W' => Colors.greenAccent,
      'D' => Colors.amber,
      'L' => Colors.redAccent,
      _ => Colors.grey,
    };

    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.only(left: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _error(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
