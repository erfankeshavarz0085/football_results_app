import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/standing_model.dart';
import '../../../providers/fixture_provider.dart';
import '../../../widgets/team_logo.dart';
import '../../team_details_screen.dart';

class StandingsTab extends StatefulWidget {
  final int leagueId;
  final String leagueName;
  final int season;

  const StandingsTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.season,
  });

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      Provider.of<FixtureProvider>(
        context,
        listen: false,
      ).loadLeagueStandings(
        widget.leagueId,
        season: widget.season,
      );
    });
  }


  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<FixtureProvider>(context);

    final standings =
        provider.getStandingsForLeague(
          widget.leagueId,
          season: widget.season,
        );


    return Scaffold(
      backgroundColor: const Color(0xff0d1117),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            if (provider.isStandingsLoading)

              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                ),
              )


            else if (provider.standingsErrorMessage != null)

              Expanded(
                child: Center(
                  child: Text(
                    provider.standingsErrorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )


            else if (standings.isEmpty)

              Expanded(
                child: Center(
                  child: Text(
                    widget.leagueId == 1
                        ? 'World Cup standings may appear after the group stage starts'
                        : 'No standings available',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )


            else

              Expanded(child: _standingsList(context, standings)),

          ],
        ),
      ),
    );
  }



  Widget _standingsList(BuildContext context, List<StandingModel> standings) {
    if (widget.leagueId != 1) {
      return ListView.builder(
        itemCount: standings.length,
        itemBuilder: (context, index) {
          final team = standings[index];

          return _standingCard(context, team);
        },
      );
    }

    final groupedStandings = _groupWorldCupStandings(standings);

    return ListView(
      children: [
        ...groupedStandings.entries.map((entry) {
          final groupTeams = entry.value.take(4).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _groupHeader(entry.key),
              ...groupTeams.map((team) => _standingCard(context, team)),
              const SizedBox(height: 6),
            ],
          );
        }),
      ],
    );
  }

  Map<String, List<StandingModel>> _groupWorldCupStandings(
    List<StandingModel> standings,
  ) {
    final grouped = <String, List<StandingModel>>{};

    for (final team in standings) {
      final group = team.group.trim().isEmpty ? 'World Cup' : team.group.trim();

      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(team);
    }

    for (final teams in grouped.values) {
      teams.sort((a, b) => a.rank.compareTo(b.rank));
    }

    return Map.fromEntries(
      grouped.entries.toList()
        ..sort(
          (a, b) => _groupSortValue(a.key).compareTo(_groupSortValue(b.key)),
        ),
    );
  }

  int _groupSortValue(String group) {
    final match = RegExp(r'Group ([A-H])').firstMatch(group);

    if (match == null) {
      return 1000 + group.hashCode.abs();
    }

    return match.group(1)!.codeUnitAt(0);
  }

  Widget _groupHeader(String groupName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.table_chart_rounded,
            color: Colors.greenAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            groupName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _standingCard(BuildContext context, StandingModel team) {

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDetailsScreen(
              teamId: team.teamId,
              fallbackName: team.teamName,
              fallbackLogo: team.teamLogo,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(

      margin: const EdgeInsets.only(
        bottom: 12,
      ),


      padding: const EdgeInsets.all(12),


      decoration: BoxDecoration(

        color: const Color(0xff161b22),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white10,
        ),

      ),


      child: Column(

        children: [


          Row(

            children: [


              Container(

                width: 30,

                alignment: Alignment.center,

                child: Text(

                  '${team.rank}',

                  style: const TextStyle(

                    color: Colors.white,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,

                  ),
                ),
              ),



              const SizedBox(width: 8),



              TeamLogo(logoUrl: team.teamLogo, size: 38),



              const SizedBox(width: 12),



              Expanded(

                child: Text(

                  team.teamName,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,


                  style: const TextStyle(

                    color: Colors.white,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 15,

                  ),

                ),

              ),



            ],
          ),



          const SizedBox(height: 14),



          Container(

            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 6,
            ),


            decoration: BoxDecoration(

              color:
                  const Color(0xff0d1117),

              borderRadius:
                  BorderRadius.circular(12),

            ),



            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,


              children: [


                _statItem(
                  'P',
                  team.played,
                ),


                _statItem(
                  'W',
                  team.win,
                ),


                _statItem(
                  'D',
                  team.draw,
                ),


                _statItem(
                  'L',
                  team.lose,
                ),


                _statItem(
                  'GF',
                  team.goalsFor,
                ),


                _statItem(
                  'GA',
                  team.goalsAgainst,
                ),


                _statItem(
                  'GD',
                  team.goalDifference,
                ),



                Column(

                  children: [

                    const Text(

                      'PTS',

                      style:
                          TextStyle(

                        color:
                            Colors.grey,

                        fontSize: 10,

                      ),

                    ),


                    Text(

                      '${team.points}',


                      style:
                          const TextStyle(

                        color:
                            Colors.greenAccent,

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 15,

                      ),

                    ),

                  ],

                ),


              ],

            ),

          ),


        ],

      ),

      ),
    );

  }




  Widget _statItem(
      String title,
      int value,
      ) {


    return Column(

      children: [


        Text(

          title,

          style:
              const TextStyle(

            color: Colors.grey,

            fontSize: 10,

          ),

        ),



        const SizedBox(
          height: 3,
        ),



        Text(

          '$value',

          style:
              const TextStyle(

            color: Colors.white,

            fontSize: 12,

            fontWeight:
                FontWeight.bold,

          ),

        ),


      ],

    );

  }

}
