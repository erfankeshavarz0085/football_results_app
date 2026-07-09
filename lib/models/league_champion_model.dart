class LeagueChampionModel {
  final String season;
  final String champion;
  final String runnerUp;
  final String note;

  const LeagueChampionModel({
    required this.season,
    required this.champion,
    this.runnerUp = '',
    this.note = '',
  });
}
