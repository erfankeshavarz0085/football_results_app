import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/match_detail_provider.dart';


class MatchDetailsScreen extends StatefulWidget {

  final int fixtureId;


  const MatchDetailsScreen({
    super.key,
    required this.fixtureId,
  });


  @override
  State<MatchDetailsScreen> createState() =>
      _MatchDetailsScreenState();

}



class _MatchDetailsScreenState
    extends State<MatchDetailsScreen> {


  @override
  void initState() {

    super.initState();


    Future.microtask(() {

      if (!mounted) return;


      Provider.of<MatchDetailProvider>(
        context,
        listen: false,
      ).loadMatchDetails(
        widget.fixtureId,
      );


    });

  }



  @override
  Widget build(BuildContext context) {


    final provider =
        Provider.of<MatchDetailProvider>(context);


    final match = provider.matchDetail;



    return Scaffold(

      backgroundColor:
          const Color(0xff0d1117),


      appBar: AppBar(

        backgroundColor:
            const Color(0xff0d1117),

        title: const Text(
          'Match Details',
        ),

      ),



      body:


      provider.isLoading

          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )


          : provider.errorMessage != null

              ? Center(
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                )


              : match == null

                  ? const Center(
                      child: Text(
                        'No match data',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )


                  : _matchBody(match),


    );

  }





  Widget _matchBody(match) {


    return SingleChildScrollView(

      padding:
          const EdgeInsets.all(16),


      child: Column(

        children: [


          Container(

            padding:
                const EdgeInsets.all(20),


            decoration: BoxDecoration(

              color:
                  const Color(0xff161b22),

              borderRadius:
                  BorderRadius.circular(24),

            ),


            child: Column(

              children: [


                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [


                    _team(
                      match.homeTeam,
                      match.homeLogo,
                    ),



                    Padding(

                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),


                      child: Column(

                        children: [


                          Text(

                            '${match.homeScore ?? "-"} - ${match.awayScore ?? "-"}',

                            style:
                                const TextStyle(

                              color:
                                  Colors.white,

                              fontSize:
                                  30,

                              fontWeight:
                                  FontWeight.bold,

                            ),

                          ),



                          const SizedBox(
                            height: 8,
                          ),



                          Text(

                            match.status,

                            style:
                                const TextStyle(

                              color:
                                  Colors.greenAccent,

                              fontWeight:
                                  FontWeight.bold,

                            ),

                          ),


                        ],

                      ),

                    ),



                    _team(
                      match.awayTeam,
                      match.awayLogo,
                    ),


                  ],

                ),


              ],

            ),

          ),




          const SizedBox(
            height: 20,
          ),




          _infoCard(
            Icons.stadium,
            'Venue',
            '${match.venue} ${match.city}',
          ),



          _infoCard(
            Icons.person,
            'Referee',
            match.referee.isEmpty
                ? 'Unknown'
                : match.referee,
          ),



        ],

      ),

    );

  }





  Widget _team(
      String name,
      String logo,
      ) {


    return Expanded(

      child: Column(

        children: [


          CachedNetworkImage(

            imageUrl: logo,

            width:
                55,

            height:
                55,


            errorWidget:
                (_,__,___) {

              return const Icon(
                Icons.shield,
                color:
                    Colors.greenAccent,
                size:
                    50,
              );

            },

          ),



          const SizedBox(
            height: 8,
          ),



          Text(

            name,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(

              color:
                  Colors.white,

              fontWeight:
                  FontWeight.bold,

            ),

          ),


        ],

      ),

    );

  }





  Widget _infoCard(
      IconData icon,
      String title,
      String value,
      ) {


    return Container(

      margin:
          const EdgeInsets.only(
            bottom: 12,
          ),


      padding:
          const EdgeInsets.all(15),


      decoration:
          BoxDecoration(

        color:
            const Color(0xff161b22),

        borderRadius:
            BorderRadius.circular(18),

      ),



      child: Row(

        children: [


          Icon(
            icon,
            color:
                Colors.greenAccent,
          ),


          const SizedBox(
            width: 12,
          ),


          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),
                ),

              ],

            ),

          ),

        ],

      ),

    );

  }


}