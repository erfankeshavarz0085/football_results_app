import 'package:flutter/material.dart';

class LeagueModel {
  final int id;
  final String name;
  final String country;
  final String season;
  final String logoUrl;
  final IconData fallbackIcon;

  const LeagueModel({
    required this.id,
    required this.name,
    required this.country,
    required this.season,
    required this.logoUrl,
    required this.fallbackIcon,
  });

  Map<String, dynamic> toOverviewMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'season': season,
      'logoUrl': logoUrl,
      'icon': fallbackIcon,
    };
  }
}

class LeagueCatalog {
  static const List<LeagueModel> topLeagues = [
    LeagueModel(
      id: 39,
      name: 'Premier League',
      country: 'England',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/39.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 140,
      name: 'La Liga',
      country: 'Spain',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/140.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 135,
      name: 'Serie A',
      country: 'Italy',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/135.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 78,
      name: 'Bundesliga',
      country: 'Germany',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/78.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 61,
      name: 'Ligue 1',
      country: 'France',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/61.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 2,
      name: 'Champions League',
      country: 'Europe',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/2.png',
      fallbackIcon: Icons.emoji_events_rounded,
    ),
    LeagueModel(
      id: 1,
      name: 'World Cup',
      country: 'International',
      season: '2026',
      logoUrl: 'https://media.api-sports.io/football/leagues/1.png',
      fallbackIcon: Icons.public_rounded,
    ),
  ];

  static LeagueModel byId(int id, String fallbackName) {
    for (final league in topLeagues) {
      if (league.id == id) {
        return league;
      }
    }

    return LeagueModel(
      id: id,
      name: fallbackName,
      country: 'Unknown',
      season: '2024/2025',
      logoUrl: 'https://media.api-sports.io/football/leagues/$id.png',
      fallbackIcon: Icons.emoji_events_rounded,
    );
  }
}
