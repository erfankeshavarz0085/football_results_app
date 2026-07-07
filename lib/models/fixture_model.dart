class FixtureModel {
  final int id;

  final int leagueId;
  final String leagueName;
  final String leagueLogo;
  final String country;
  final String countryFlag;
  final String round;
  final int season;

  final int homeTeamId;
  final int awayTeamId;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;

  final int? homeScore;
  final int? awayScore;

  final String status;
  final String date;

  final String venueName;
  final String venueCity;
  final String referee;

  FixtureModel({
    required this.id,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    required this.country,
    required this.countryFlag,
    required this.round,
    required this.season,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.date,
    required this.venueName,
    required this.venueCity,
    required this.referee,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      id: json['fixture']?['id'] ?? 0,

      leagueId: json['league']?['id'] ?? 0,
      leagueName: json['league']?['name'] ?? '',
      leagueLogo: json['league']?['logo'] ?? '',
      country: json['league']?['country'] ?? '',
      countryFlag: json['league']?['flag'] ?? '',
      round: json['league']?['round'] ?? '',
      season: json['league']?['season'] ?? 0,

      homeTeamId: json['teams']?['home']?['id'] ?? 0,
      awayTeamId: json['teams']?['away']?['id'] ?? 0,
      homeTeam: json['teams']?['home']?['name'] ?? '',
      awayTeam: json['teams']?['away']?['name'] ?? '',
      homeLogo: json['teams']?['home']?['logo'] ?? '',
      awayLogo: json['teams']?['away']?['logo'] ?? '',

      homeScore: json['goals']?['home'],
      awayScore: json['goals']?['away'],

      status: json['fixture']?['status']?['short'] ?? '',
      date: json['fixture']?['date'] ?? '',

      venueName: json['fixture']?['venue']?['name'] ?? '',
      venueCity: json['fixture']?['venue']?['city'] ?? '',
      referee: json['fixture']?['referee'] ?? '',
    );
  }
}