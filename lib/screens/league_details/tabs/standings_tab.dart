import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/standing_model.dart';
import '../../../providers/fixture_provider.dart';

class StandingsTab extends StatefulWidget {
  final int leagueId;
  final String leagueName;

  const StandingsTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
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
      ).loadLeagueStandings(widget.leagueId);
    });
  }


  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<FixtureProvider>(context);

    final standings =
        provider.getStandingsForLeague(widget.leagueId);


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

              const Expanded(
                child: Center(
                  child: Text(
                    'No standings available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )


            else

              Expanded(
                child: ListView.builder(

                  itemCount: standings.length,

                  itemBuilder: (context, index) {

                    final team = standings[index];

                    return _standingCard(team);

                  },
                ),
              ),

          ],
        ),
      ),
    );
  }



  Widget _standingCard(StandingModel team) {

    return Container(

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



              CachedNetworkImage(

                imageUrl: team.teamLogo,

                width: 38,

                height: 38,


                errorWidget:
                    (_, __, ___) {

                  return const Icon(

                    Icons.shield,

                    color:
                        Colors.greenAccent,

                    size: 32,

                  );

                },

              ),



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