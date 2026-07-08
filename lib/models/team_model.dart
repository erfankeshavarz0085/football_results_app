import 'fixture_model.dart';

class TeamModel {
  final int id;
  final String name;
  final String country;
  final String logo;
  final int founded;
  final String venueName;
  final String venueCity;
  final int venueCapacity;

  TeamModel({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.founded,
    required this.venueName,
    required this.venueCity,
    required this.venueCapacity,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final team = json['team'] ?? {};
    final venue = json['venue'] ?? {};

    return TeamModel(
      id: team['id'] ?? 0,
      name: team['name'] ?? '',
      country: team['country'] ?? '',
      logo: team['logo'] ?? '',
      founded: team['founded'] ?? 0,
      venueName: venue['name'] ?? '',
      venueCity: venue['city'] ?? '',
      venueCapacity: venue['capacity'] ?? 0,
    );
  }
}

class TeamDetailsModel {
  final TeamModel team;
  final List<FixtureModel> recentFixtures;

  TeamDetailsModel({
    required this.team,
    required this.recentFixtures,
  });

  List<String> get form {
    return recentFixtures.take(5).map((fixture) {
      final isHome = fixture.homeTeamId == team.id;
      final teamScore = isHome ? fixture.homeScore : fixture.awayScore;
      final opponentScore = isHome ? fixture.awayScore : fixture.homeScore;

      if (teamScore == null || opponentScore == null) {
        return 'N';
      }

      if (teamScore > opponentScore) return 'W';
      if (teamScore < opponentScore) return 'L';
      return 'D';
    }).toList();
  }
}
