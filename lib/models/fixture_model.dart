class FixtureModel {
  final int id;
  final String leagueName;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final String date;

  FixtureModel({
    required this.id,
    required this.leagueName,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.date,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      id: json['fixture']['id'],
      leagueName: json['league']['name'] ?? '',
      homeTeam: json['teams']['home']['name'] ?? '',
      awayTeam: json['teams']['away']['name'] ?? '',
      homeLogo: json['teams']['home']['logo'] ?? '',
      awayLogo: json['teams']['away']['logo'] ?? '',
      homeScore: json['goals']['home'],
      awayScore: json['goals']['away'],
      status: json['fixture']['status']['short'] ?? '',
      date: json['fixture']['date'] ?? '',
    );
  }
}