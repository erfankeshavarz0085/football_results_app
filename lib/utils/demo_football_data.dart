import '../models/fixture_model.dart';
import '../models/league_model.dart';
import '../models/match_detail_model.dart';
import '../models/standing_model.dart';
import '../models/team_model.dart';

class DemoFootballData {
  static List<TeamModel> teams() {
    return [
      _team(
        id: 40,
        name: 'Liverpool',
        country: 'England',
        founded: 1892,
        venueName: 'Anfield',
        venueCity: 'Liverpool',
        venueCapacity: 61276,
      ),
      _team(
        id: 33,
        name: 'Manchester United',
        country: 'England',
        founded: 1878,
        venueName: 'Old Trafford',
        venueCity: 'Manchester',
        venueCapacity: 74310,
      ),
      _team(
        id: 42,
        name: 'Arsenal',
        country: 'England',
        founded: 1886,
        venueName: 'Emirates Stadium',
        venueCity: 'London',
        venueCapacity: 60383,
      ),
      _team(
        id: 541,
        name: 'Real Madrid',
        country: 'Spain',
        founded: 1902,
        venueName: 'Santiago Bernabeu',
        venueCity: 'Madrid',
        venueCapacity: 81044,
      ),
      _team(
        id: 529,
        name: 'Barcelona',
        country: 'Spain',
        founded: 1899,
        venueName: 'Camp Nou',
        venueCity: 'Barcelona',
        venueCapacity: 99354,
      ),
      _team(
        id: 157,
        name: 'Bayern Munich',
        country: 'Germany',
        founded: 1900,
        venueName: 'Allianz Arena',
        venueCity: 'Munich',
        venueCapacity: 75000,
      ),
      _team(
        id: 85,
        name: 'Paris Saint-Germain',
        country: 'France',
        founded: 1970,
        venueName: 'Parc des Princes',
        venueCity: 'Paris',
        venueCapacity: 47929,
      ),
      _team(
        id: 505,
        name: 'Inter Milan',
        country: 'Italy',
        founded: 1908,
        venueName: 'San Siro',
        venueCity: 'Milan',
        venueCapacity: 80018,
      ),
    ];
  }

  static List<TeamModel> searchTeams(String query) {
    final trimmedQuery = query.toLowerCase().trim();

    if (trimmedQuery.length < 3) {
      return const [];
    }

    return teams().where((team) {
      return team.name.toLowerCase().contains(trimmedQuery) ||
          team.country.toLowerCase().contains(trimmedQuery);
    }).toList();
  }

  static List<LeagueModel> searchLeagues(String query) {
    final trimmedQuery = query.toLowerCase().trim();

    if (trimmedQuery.length < 3) {
      return const [];
    }

    return LeagueCatalog.topLeagues.where((league) {
      return league.name.toLowerCase().contains(trimmedQuery) ||
          league.country.toLowerCase().contains(trimmedQuery);
    }).toList();
  }

  static TeamDetailsModel? teamDetailsForTeam(int teamId) {
    TeamModel? team;

    for (final item in teams()) {
      if (item.id == teamId) {
        team = item;
        break;
      }
    }

    if (team == null) {
      return null;
    }

    return TeamDetailsModel(
      team: team,
      recentFixtures: _recentFixturesForTeam(team),
      squad: _demoSquad(team),
      coach: _demoCoach(team),
      lineup: TeamLineupSummaryModel(
        formation: '4-3-3',
        startXI: _demoSquad(team).take(11).toList(),
      ),
    );
  }

  static List<FixtureModel> fixturesForDate(DateTime date) {
    final matchDate = _dateTime(date, 20, 30);

    return [
      _fixture(
        id: -3901,
        leagueId: 39,
        leagueName: 'Premier League',
        country: 'England',
        season: 2024,
        round: 'Regular Season - 12',
        homeTeamId: 33,
        awayTeamId: 40,
        homeTeam: 'Manchester United',
        awayTeam: 'Liverpool',
        homeScore: 2,
        awayScore: 2,
        status: 'FT',
        date: matchDate,
        venueName: 'Old Trafford',
        venueCity: 'Manchester',
      ),
      _fixture(
        id: -14001,
        leagueId: 140,
        leagueName: 'La Liga',
        country: 'Spain',
        season: 2024,
        round: 'Regular Season - 10',
        homeTeamId: 529,
        awayTeamId: 541,
        homeTeam: 'Barcelona',
        awayTeam: 'Real Madrid',
        homeScore: 1,
        awayScore: 3,
        status: 'FT',
        date: _dateTime(date, 23, 0),
        venueName: 'Estadi Olimpic Lluis Companys',
        venueCity: 'Barcelona',
      ),
      _fixture(
        id: -13501,
        leagueId: 135,
        leagueName: 'Serie A',
        country: 'Italy',
        season: 2024,
        round: 'Regular Season - 9',
        homeTeamId: 489,
        awayTeamId: 505,
        homeTeam: 'AC Milan',
        awayTeam: 'Inter Milan',
        homeScore: null,
        awayScore: null,
        status: 'NS',
        date: _dateTime(date, 22, 15),
        venueName: 'San Siro',
        venueCity: 'Milan',
      ),
      _fixture(
        id: -7801,
        leagueId: 78,
        leagueName: 'Bundesliga',
        country: 'Germany',
        season: 2024,
        round: 'Regular Season - 8',
        homeTeamId: 157,
        awayTeamId: 165,
        homeTeam: 'Bayern Munich',
        awayTeam: 'Borussia Dortmund',
        homeScore: 4,
        awayScore: 1,
        status: 'FT',
        date: _dateTime(date, 18, 0),
        venueName: 'Allianz Arena',
        venueCity: 'Munich',
      ),
      _fixture(
        id: -6101,
        leagueId: 61,
        leagueName: 'Ligue 1',
        country: 'France',
        season: 2024,
        round: 'Regular Season - 11',
        homeTeamId: 85,
        awayTeamId: 81,
        homeTeam: 'Paris Saint-Germain',
        awayTeam: 'Marseille',
        homeScore: null,
        awayScore: null,
        status: 'NS',
        date: _dateTime(date, 21, 45),
        venueName: 'Parc des Princes',
        venueCity: 'Paris',
      ),
      _fixture(
        id: -201,
        leagueId: 2,
        leagueName: 'Champions League',
        country: 'Europe',
        season: 2024,
        round: 'League Stage - 4',
        homeTeamId: 50,
        awayTeamId: 541,
        homeTeam: 'Manchester City',
        awayTeam: 'Real Madrid',
        homeScore: 2,
        awayScore: 1,
        status: 'FT',
        date: _dateTime(date, 23, 30),
        venueName: 'Etihad Stadium',
        venueCity: 'Manchester',
      ),
    ];
  }

  static List<FixtureModel> liveFixtures() {
    final now = DateTime.now();

    return [
      _fixture(
        id: -9001,
        leagueId: 39,
        leagueName: 'Premier League',
        country: 'England',
        season: 2024,
        round: 'Regular Season - 15',
        homeTeamId: 42,
        awayTeamId: 49,
        homeTeam: 'Arsenal',
        awayTeam: 'Chelsea',
        homeScore: 1,
        awayScore: 1,
        status: '2H',
        date: _dateTime(now, now.hour, now.minute),
        venueName: 'Emirates Stadium',
        venueCity: 'London',
      ),
      _fixture(
        id: -9002,
        leagueId: 2,
        leagueName: 'Champions League',
        country: 'Europe',
        season: 2024,
        round: 'League Stage - 5',
        homeTeamId: 541,
        awayTeamId: 85,
        homeTeam: 'Real Madrid',
        awayTeam: 'Paris Saint-Germain',
        homeScore: 0,
        awayScore: 1,
        status: '1H',
        date: _dateTime(now, now.hour, now.minute),
        venueName: 'Santiago Bernabeu',
        venueCity: 'Madrid',
      ),
    ];
  }

  static List<FixtureModel> leagueFixtures(int leagueId) {
    if (leagueId == 1) {
      return worldCupFixtures();
    }

    return fixturesForDate(DateTime.now()).where((fixture) {
      return fixture.leagueId == leagueId;
    }).toList();
  }

  static List<FixtureModel> worldCupFixtures() {
    final date = DateTime(2022, 12, 18);

    return [
      _fixture(
        id: -1001,
        leagueId: 1,
        leagueName: 'World Cup',
        country: 'International',
        season: 2022,
        round: 'Final',
        homeTeamId: 26,
        awayTeamId: 2,
        homeTeam: 'Argentina',
        awayTeam: 'France',
        homeScore: 3,
        awayScore: 3,
        status: 'PEN',
        date: _dateTime(date, 18, 0),
        venueName: 'Lusail Iconic Stadium',
        venueCity: 'Lusail',
      ),
      _fixture(
        id: -1002,
        leagueId: 1,
        leagueName: 'World Cup',
        country: 'International',
        season: 2022,
        round: '3rd Place Final',
        homeTeamId: 3,
        awayTeamId: 1,
        homeTeam: 'Croatia',
        awayTeam: 'Morocco',
        homeScore: 2,
        awayScore: 1,
        status: 'FT',
        date: _dateTime(DateTime(2022, 12, 17), 18, 0),
        venueName: 'Khalifa International Stadium',
        venueCity: 'Doha',
      ),
    ];
  }

  static List<StandingModel> standingsForLeague(int leagueId) {
    switch (leagueId) {
      case 1:
        return [
          ..._standings([
            ('Netherlands', 7, 4),
            ('Senegal', 6, 1),
            ('Ecuador', 4, 1),
            ('Qatar', 0, -6),
          ], group: 'Group A'),
          ..._standings([
            ('England', 7, 7),
            ('United States', 5, 1),
            ('Iran', 3, -3),
            ('Wales', 1, -5),
          ], group: 'Group B'),
        ];
      case 39:
        return _standings([
          ('Liverpool', 40, 18),
          ('Manchester City', 37, 15),
          ('Arsenal', 36, 14),
          ('Chelsea', 31, 8),
        ]);
      case 140:
        return _standings([
          ('Real Madrid', 42, 20),
          ('Barcelona', 39, 17),
          ('Atletico Madrid', 34, 10),
          ('Athletic Club', 29, 6),
        ]);
      case 135:
        return _standings([
          ('Inter Milan', 41, 19),
          ('Napoli', 38, 15),
          ('AC Milan', 33, 8),
          ('Juventus', 32, 7),
        ]);
      case 78:
        return _standings([
          ('Bayern Munich', 43, 24),
          ('Bayer Leverkusen', 38, 18),
          ('Borussia Dortmund', 31, 9),
          ('RB Leipzig', 29, 7),
        ]);
      case 61:
        return _standings([
          ('Paris Saint-Germain', 44, 23),
          ('Marseille', 34, 11),
          ('Monaco', 32, 10),
          ('Lille', 30, 7),
        ]);
      default:
        return const [];
    }
  }

  static MatchDetailModel? matchDetailsForFixture(int fixtureId) {
    final allFixtures = [
      ...fixturesForDate(DateTime.now()),
      ...liveFixtures(),
      ...worldCupFixtures(),
    ];

    FixtureModel? fixture;

    for (final item in allFixtures) {
      if (item.id == fixtureId) {
        fixture = item;
        break;
      }
    }

    if (fixture == null) {
      return null;
    }

    return MatchDetailModel(
      fixtureId: fixture.id,
      referee: fixture.referee,
      venue: fixture.venueName,
      city: fixture.venueCity,
      homeTeam: fixture.homeTeam,
      awayTeam: fixture.awayTeam,
      homeTeamId: fixture.homeTeamId,
      awayTeamId: fixture.awayTeamId,
      homeLogo: fixture.homeLogo,
      awayLogo: fixture.awayLogo,
      homeScore: fixture.homeScore,
      awayScore: fixture.awayScore,
      status: fixture.status,
      events: _eventsForFixture(fixture),
      statistics: _statisticsForFixture(fixture),
      lineups: const [],
    );
  }

  static List<MatchEventModel> _eventsForFixture(FixtureModel fixture) {
    if (fixture.homeScore == null && fixture.awayScore == null) {
      return const [];
    }

    return [
      MatchEventModel(
        elapsed: 18,
        extra: null,
        teamId: fixture.homeTeamId,
        teamName: fixture.homeTeam,
        playerName: '${fixture.homeTeam} Forward',
        assistName: '${fixture.homeTeam} Midfielder',
        type: 'Goal',
        detail: 'Normal Goal',
        comments: '',
      ),
      MatchEventModel(
        elapsed: 54,
        extra: null,
        teamId: fixture.awayTeamId,
        teamName: fixture.awayTeam,
        playerName: '${fixture.awayTeam} Forward',
        assistName: '',
        type: 'Goal',
        detail: 'Normal Goal',
        comments: '',
      ),
    ];
  }

  static List<MatchStatisticModel> _statisticsForFixture(FixtureModel fixture) {
    return [
      MatchStatisticModel(
        teamName: fixture.homeTeam,
        teamLogo: fixture.homeLogo,
        items: [
          StatisticItemModel(type: 'Ball Possession', value: '54%'),
          StatisticItemModel(type: 'Total Shots', value: '13'),
          StatisticItemModel(type: 'Shots on Goal', value: '6'),
        ],
      ),
      MatchStatisticModel(
        teamName: fixture.awayTeam,
        teamLogo: fixture.awayLogo,
        items: [
          StatisticItemModel(type: 'Ball Possession', value: '46%'),
          StatisticItemModel(type: 'Total Shots', value: '10'),
          StatisticItemModel(type: 'Shots on Goal', value: '4'),
        ],
      ),
    ];
  }

  static FixtureModel _fixture({
    required int id,
    required int leagueId,
    required String leagueName,
    required String country,
    required int season,
    required String round,
    required int homeTeamId,
    required int awayTeamId,
    required String homeTeam,
    required String awayTeam,
    required int? homeScore,
    required int? awayScore,
    required String status,
    required DateTime date,
    required String venueName,
    required String venueCity,
  }) {
    return FixtureModel(
      id: id,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueLogo: 'https://media.api-sports.io/football/leagues/$leagueId.png',
      country: country,
      countryFlag: '',
      round: round,
      season: season,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeLogo: 'https://media.api-sports.io/football/teams/$homeTeamId.png',
      awayLogo: 'https://media.api-sports.io/football/teams/$awayTeamId.png',
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      date: date.toIso8601String(),
      venueName: venueName,
      venueCity: venueCity,
      referee: 'Demo Referee',
    );
  }

  static TeamModel _team({
    required int id,
    required String name,
    required String country,
    required int founded,
    required String venueName,
    required String venueCity,
    required int venueCapacity,
  }) {
    return TeamModel(
      id: id,
      name: name,
      country: country,
      logo: 'https://media.api-sports.io/football/teams/$id.png',
      founded: founded,
      venueName: venueName,
      venueCity: venueCity,
      venueCapacity: venueCapacity,
    );
  }

  static List<FixtureModel> _recentFixturesForTeam(TeamModel team) {
    final fixtures = [
      ...fixturesForDate(DateTime.now()),
      ...liveFixtures(),
      ...worldCupFixtures(),
    ];

    return fixtures.where((fixture) {
      return fixture.homeTeamId == team.id || fixture.awayTeamId == team.id;
    }).toList();
  }

  static TeamCoachModel _demoCoach(TeamModel team) {
    return TeamCoachModel(
      id: team.id + 100000,
      name: '${team.name} Coach',
      age: 48,
      nationality: team.country,
      photo: '',
    );
  }

  static List<TeamPlayerModel> _demoSquad(TeamModel team) {
    final positions = ['G', 'D', 'D', 'D', 'D', 'M', 'M', 'M', 'F', 'F', 'F'];

    return List.generate(18, (index) {
      return TeamPlayerModel(
        id: team.id * 100 + index,
        name: '${team.name} Player ${index + 1}',
        age: 20 + (index % 12),
        number: index + 1,
        position: index < positions.length ? positions[index] : 'Sub',
        photo: '',
      );
    });
  }

  static List<StandingModel> _standings(
    List<(String teamName, int points, int goalDifference)> teams,
    {String group = ''}
  ) {
    return teams.indexed.map((entry) {
      final index = entry.$1;
      final team = entry.$2;
      final played = 18;
      final wins = 10 + (teams.length - index);
      final draws = 3;
      final losses = played - wins - draws;

      return StandingModel(
        rank: index + 1,
        teamId: 90000 + index,
        teamName: team.$1,
        teamLogo: '',
        played: played,
        win: wins,
        draw: draws,
        lose: losses < 0 ? 0 : losses,
        goalsFor: 36 - index * 3,
        goalsAgainst: 18 + index * 2,
        goalDifference: team.$3,
        points: team.$2,
        description: index < 4 ? 'Demo table' : '',
        group: group,
      );
    }).toList();
  }

  static DateTime _dateTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
