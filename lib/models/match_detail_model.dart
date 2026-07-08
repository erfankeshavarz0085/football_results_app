class MatchDetailModel {
  final int fixtureId;

  final String referee;

  final String venue;
  final String city;

  final String homeTeam;
  final String awayTeam;

  final String homeLogo;
  final String awayLogo;

  final int? homeScore;
  final int? awayScore;

  final String status;

  final List<MatchEventModel> events;
  final List<MatchStatisticModel> statistics;
  final List<MatchLineupModel> lineups;

  MatchDetailModel({
    required this.fixtureId,
    required this.referee,
    required this.venue,
    required this.city,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    this.events = const [],
    this.statistics = const [],
    this.lineups = const [],
  });

  factory MatchDetailModel.fromJson(
    Map<String, dynamic> json, {
    List<MatchEventModel> events = const [],
    List<MatchStatisticModel> statistics = const [],
    List<MatchLineupModel> lineups = const [],
  }) {
    return MatchDetailModel(
      fixtureId: json['fixture']?['id'] ?? 0,
      referee: json['fixture']?['referee'] ?? '',
      venue: json['fixture']?['venue']?['name'] ?? '',
      city: json['fixture']?['venue']?['city'] ?? '',
      homeTeam: json['teams']?['home']?['name'] ?? '',
      awayTeam: json['teams']?['away']?['name'] ?? '',
      homeLogo: json['teams']?['home']?['logo'] ?? '',
      awayLogo: json['teams']?['away']?['logo'] ?? '',
      homeScore: json['goals']?['home'],
      awayScore: json['goals']?['away'],
      status: json['fixture']?['status']?['short'] ?? '',
      events: events,
      statistics: statistics,
      lineups: lineups,
    );
  }
}

class MatchEventModel {
  final int elapsed;
  final int? extra;
  final int teamId;
  final String teamName;
  final String playerName;
  final String assistName;
  final String type;
  final String detail;
  final String comments;

  MatchEventModel({
    required this.elapsed,
    required this.extra,
    required this.teamId,
    required this.teamName,
    required this.playerName,
    required this.assistName,
    required this.type,
    required this.detail,
    required this.comments,
  });

  factory MatchEventModel.fromJson(Map<String, dynamic> json) {
    return MatchEventModel(
      elapsed: json['time']?['elapsed'] ?? 0,
      extra: json['time']?['extra'],
      teamId: json['team']?['id'] ?? 0,
      teamName: json['team']?['name'] ?? '',
      playerName: json['player']?['name'] ?? '',
      assistName: json['assist']?['name'] ?? '',
      type: json['type'] ?? '',
      detail: json['detail'] ?? '',
      comments: json['comments'] ?? '',
    );
  }

  String get minute {
    if (extra == null || extra == 0) {
      return "$elapsed'";
    }

    return "$elapsed+$extra'";
  }
}

class MatchStatisticModel {
  final String teamName;
  final String teamLogo;
  final List<StatisticItemModel> items;

  MatchStatisticModel({
    required this.teamName,
    required this.teamLogo,
    required this.items,
  });

  factory MatchStatisticModel.fromJson(Map<String, dynamic> json) {
    final List stats = json['statistics'] ?? [];

    return MatchStatisticModel(
      teamName: json['team']?['name'] ?? '',
      teamLogo: json['team']?['logo'] ?? '',
      items: stats.map((item) => StatisticItemModel.fromJson(item)).toList(),
    );
  }
}

class StatisticItemModel {
  final String type;
  final String value;

  StatisticItemModel({
    required this.type,
    required this.value,
  });

  factory StatisticItemModel.fromJson(Map<String, dynamic> json) {
    return StatisticItemModel(
      type: json['type'] ?? '',
      value: json['value']?.toString() ?? '-',
    );
  }
}

class MatchLineupModel {
  final String teamName;
  final String teamLogo;
  final String formation;
  final String coachName;
  final List<LineupPlayerModel> startXI;
  final List<LineupPlayerModel> substitutes;

  MatchLineupModel({
    required this.teamName,
    required this.teamLogo,
    required this.formation,
    required this.coachName,
    required this.startXI,
    required this.substitutes,
  });

  factory MatchLineupModel.fromJson(Map<String, dynamic> json) {
    final List startXI = json['startXI'] ?? [];
    final List substitutes = json['substitutes'] ?? [];

    return MatchLineupModel(
      teamName: json['team']?['name'] ?? '',
      teamLogo: json['team']?['logo'] ?? '',
      formation: json['formation'] ?? '',
      coachName: json['coach']?['name'] ?? '',
      startXI: startXI.map((item) {
        return LineupPlayerModel.fromJson(item['player'] ?? {});
      }).toList(),
      substitutes: substitutes.map((item) {
        return LineupPlayerModel.fromJson(item['player'] ?? {});
      }).toList(),
    );
  }
}

class LineupPlayerModel {
  final int id;
  final String name;
  final int? number;
  final String position;
  final String grid;

  LineupPlayerModel({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.grid,
  });

  factory LineupPlayerModel.fromJson(Map<String, dynamic> json) {
    return LineupPlayerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      number: json['number'],
      position: json['pos'] ?? '',
      grid: json['grid'] ?? '',
    );
  }
}
