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
  final List<TeamPlayerModel> squad;
  final TeamCoachModel? coach;
  final TeamLineupSummaryModel? lineup;

  TeamDetailsModel({
    required this.team,
    required this.recentFixtures,
    this.squad = const [],
    this.coach,
    this.lineup,
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

class TeamPlayerModel {
  final int id;
  final String name;
  final int? age;
  final int? number;
  final String position;
  final String photo;

  TeamPlayerModel({
    required this.id,
    required this.name,
    required this.age,
    required this.number,
    required this.position,
    required this.photo,
  });

  factory TeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return TeamPlayerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'],
      number: json['number'],
      position: json['position'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}

class TeamCoachModel {
  final int id;
  final String name;
  final int? age;
  final String nationality;
  final String photo;

  TeamCoachModel({
    required this.id,
    required this.name,
    required this.age,
    required this.nationality,
    required this.photo,
  });

  factory TeamCoachModel.fromJson(Map<String, dynamic> json) {
    return TeamCoachModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'],
      nationality: json['nationality'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}

class TeamLineupSummaryModel {
  final String formation;
  final List<TeamPlayerModel> startXI;

  TeamLineupSummaryModel({
    required this.formation,
    required this.startXI,
  });

  factory TeamLineupSummaryModel.fromJson(Map<String, dynamic> json) {
    final List startXI = json['startXI'] ?? [];

    return TeamLineupSummaryModel(
      formation: json['formation'] ?? '',
      startXI: startXI.map((item) {
        return TeamPlayerModel.fromJson(item['player'] ?? {});
      }).toList(),
    );
  }
}
