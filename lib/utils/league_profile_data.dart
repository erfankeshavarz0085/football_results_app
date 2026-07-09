import '../models/league_profile_model.dart';

class LeagueProfileData {
  static const Map<int, LeagueProfileModel> profiles = {
    39: LeagueProfileModel(
      founded: '1992',
      type: 'Domestic league',
      teams: '20',
      region: 'England',
      format: 'Double round-robin',
      about:
          'England top division and one of the most watched football leagues in the world.',
    ),
    140: LeagueProfileModel(
      founded: '1929',
      type: 'Domestic league',
      teams: '20',
      region: 'Spain',
      format: 'Double round-robin',
      about:
          'Spain top division, home to historic clubs and one of Europe strongest title races.',
    ),
    135: LeagueProfileModel(
      founded: '1898',
      type: 'Domestic league',
      teams: '20',
      region: 'Italy',
      format: 'Double round-robin',
      about:
          'Italy top division, known for tactical football, strong rivalries and historic clubs.',
    ),
    78: LeagueProfileModel(
      founded: '1963',
      type: 'Domestic league',
      teams: '18',
      region: 'Germany',
      format: 'Double round-robin',
      about:
          'Germany top division, famous for high tempo football and strong supporter culture.',
    ),
    61: LeagueProfileModel(
      founded: '1932',
      type: 'Domestic league',
      teams: '18',
      region: 'France',
      format: 'Double round-robin',
      about:
          'France top division and a major development ground for elite European talent.',
    ),
    2: LeagueProfileModel(
      founded: '1955',
      type: 'Continental cup',
      teams: '36',
      region: 'Europe',
      format: 'League phase and knockouts',
      about:
          'Europe premier club competition, bringing together the strongest clubs on the continent.',
    ),
    1: LeagueProfileModel(
      founded: '1930',
      type: 'International tournament',
      teams: '32',
      region: 'World',
      format: 'Groups and knockouts',
      about:
          'The biggest international football tournament, played by national teams every four years.',
    ),
  };

  static LeagueProfileModel? byLeagueId(int leagueId) {
    return profiles[leagueId];
  }
}
