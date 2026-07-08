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

  });


  factory MatchDetailModel.fromJson(
      Map<String,dynamic> json) {

    return MatchDetailModel(

      fixtureId:
          json['fixture']?['id'] ?? 0,


      referee:
          json['fixture']?['referee'] ?? '',


      venue:
          json['fixture']?['venue']?['name'] ?? '',


      city:
          json['fixture']?['venue']?['city'] ?? '',


      homeTeam:
          json['teams']?['home']?['name'] ?? '',


      awayTeam:
          json['teams']?['away']?['name'] ?? '',


      homeLogo:
          json['teams']?['home']?['logo'] ?? '',


      awayLogo:
          json['teams']?['away']?['logo'] ?? '',


      homeScore:
          json['goals']?['home'],


      awayScore:
          json['goals']?['away'],


      status:
          json['fixture']?['status']?['short'] ?? '',

    );
  }

}