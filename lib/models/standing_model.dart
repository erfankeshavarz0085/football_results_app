class StandingModel {
  final int rank;

  final int teamId;
  final String teamName;
  final String teamLogo;

  final int played;
  final int win;
  final int draw;
  final int lose;

  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  final int points;

  final String description;

  StandingModel({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
    required this.description,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    return StandingModel(
      rank: json['rank'] ?? 0,

      teamId: json['team']?['id'] ?? 0,
      teamName: json['team']?['name'] ?? '',
      teamLogo: json['team']?['logo'] ?? '',

      played: json['all']?['played'] ?? 0,
      win: json['all']?['win'] ?? 0,
      draw: json['all']?['draw'] ?? 0,
      lose: json['all']?['lose'] ?? 0,

      goalsFor: json['all']?['goals']?['for'] ?? 0,
      goalsAgainst: json['all']?['goals']?['against'] ?? 0,

      goalDifference: json['goalsDiff'] ?? 0,

      points: json['points'] ?? 0,

      description: json['description'] ?? '',
    );
  }
}