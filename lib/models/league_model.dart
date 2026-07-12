import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LeagueModel {
  final int id;
  final String name;
  final String country;
  final String season;
  final int apiSeason;
  final String logoUrl;
  final IconData fallbackIcon;
  final List<int> availableSeasons;

  const LeagueModel({
    required this.id,
    required this.name,
    required this.country,
    required this.season,
    required this.apiSeason,
    required this.logoUrl,
    required this.fallbackIcon,
    this.availableSeasons = const [],
  });

  Map<String, dynamic> toOverviewMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'season': season,
      'apiSeason': apiSeason,
      'logoUrl': logoUrl,
      'icon': fallbackIcon,
      'availableSeasons': availableSeasons,
    };
  }
}

class LeagueCatalog {
  static List<LeagueModel> get topLeagues => [
    LeagueModel(
      id: 39,
      name: 'Premier League',
      country: 'England',
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/39.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 140,
      name: 'La Liga',
      country: 'Spain',
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/140.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 135,
      name: 'Serie A',
      country: 'Italy',
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/135.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 78,
      name: 'Bundesliga',
      country: 'Germany',
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/78.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 61,
      name: 'Ligue 1',
      country: 'France',
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/61.png',
      fallbackIcon: Icons.sports_soccer,
    ),
    LeagueModel(
      id: 2,
      name: 'Champions League',
      country: 'Europe',
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/2.png',
      fallbackIcon: Icons.emoji_events_rounded,
    ),
    LeagueModel(
      id: 1,
      name: 'World Cup',
      country: 'International',
      season: '2022',
      apiSeason: 2022,
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
      season: AppConstants.currentSeasonLabel,
      apiSeason: AppConstants.currentSeason,
      logoUrl: 'https://media.api-sports.io/football/leagues/$id.png',
      fallbackIcon: Icons.emoji_events_rounded,
    );
  }
}
