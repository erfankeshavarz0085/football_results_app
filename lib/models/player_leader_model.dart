class PlayerLeaderModel {
  final int playerId;
  final String playerName;
  final String playerPhoto;
  final int teamId;
  final String teamName;
  final String teamLogo;
  final int value;

  const PlayerLeaderModel({
    required this.playerId,
    required this.playerName,
    required this.playerPhoto,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.value,
  });
}

class LeaguePlayerLeaders {
  final List<PlayerLeaderModel> scorers;
  final List<PlayerLeaderModel> assists;
  final List<PlayerLeaderModel> cleanSheets;

  const LeaguePlayerLeaders({
    required this.scorers,
    required this.assists,
    required this.cleanSheets,
  });
}
