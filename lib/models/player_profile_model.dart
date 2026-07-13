class PlayerProfileModel {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final int? age;
  final String birthDate;
  final String birthPlace;
  final String birthCountry;
  final String nationality;
  final String height;
  final String weight;
  final int? number;
  final String position;
  final String photo;

  const PlayerProfileModel({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.birthDate,
    required this.birthPlace,
    required this.birthCountry,
    required this.nationality,
    required this.height,
    required this.weight,
    required this.number,
    required this.position,
    required this.photo,
  });

  factory PlayerProfileModel.fromJson(dynamic json) {
    final player = json['player'] ?? json;
    final birth = player['birth'] ?? {};
    return PlayerProfileModel(
      id: player['id'] ?? 0,
      name: player['name'] ?? 'Unknown player',
      firstName: player['firstname'] ?? '',
      lastName: player['lastname'] ?? '',
      age: player['age'],
      birthDate: birth['date'] ?? '',
      birthPlace: birth['place'] ?? '',
      birthCountry: birth['country'] ?? '',
      nationality: player['nationality'] ?? '',
      height: player['height']?.toString() ?? '',
      weight: player['weight']?.toString() ?? '',
      number: player['number'],
      position: player['position'] ?? '',
      photo: player['photo'] ?? '',
    );
  }
}

class PlayerCareerSpan {
  final int teamId;
  final String teamName;
  final String teamLogo;
  final int fromSeason;
  final int toSeason;

  const PlayerCareerSpan({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.fromSeason,
    required this.toSeason,
  });

  String get label =>
      fromSeason == toSeason
          ? '$fromSeason/${fromSeason + 1}'
          : '$fromSeason-${toSeason + 1}';
}

class PlayerTrophyModel {
  final String league;
  final String country;
  final String season;
  final String place;
  final String teamName;

  const PlayerTrophyModel({
    required this.league,
    required this.country,
    required this.season,
    required this.place,
    this.teamName = '',
  });

  factory PlayerTrophyModel.fromJson(dynamic json) {
    return PlayerTrophyModel(
      league: json['league'] ?? 'Unknown competition',
      country: json['country'] ?? '',
      season: json['season'] ?? '',
      place: json['place'] ?? '',
    );
  }

  PlayerTrophyModel withTeam(String team) {
    return PlayerTrophyModel(
      league: league,
      country: country,
      season: season,
      place: place,
      teamName: team,
    );
  }
}

class PlayerDetailsModel {
  final PlayerProfileModel profile;
  final List<PlayerCareerSpan> career;
  final List<PlayerTrophyModel> trophies;

  const PlayerDetailsModel({
    required this.profile,
    required this.career,
    required this.trophies,
  });

  int get winnerCount =>
      trophies.where((trophy) => trophy.place == 'Winner').length;
}
