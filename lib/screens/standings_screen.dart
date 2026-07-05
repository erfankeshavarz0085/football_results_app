import 'package:flutter/material.dart';

class StandingsScreen extends StatelessWidget {
  final String leagueName;
  final int leagueId;

  const StandingsScreen({
    super.key,
    required this.leagueName,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    final teams = [
      ['Manchester City', '18', '42'],
      ['Liverpool', '18', '40'],
      ['Arsenal', '18', '38'],
      ['Chelsea', '18', '34'],
      ['Tottenham', '18', '31'],
    ];

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: Text(leagueName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Standings',
            style: TextStyle(
              color: Colors.greenAccent.shade100,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.grey))),
                    Expanded(child: Text('Team', style: TextStyle(color: Colors.grey))),
                    SizedBox(width: 45, child: Text('P', style: TextStyle(color: Colors.grey))),
                    SizedBox(width: 45, child: Text('Pts', style: TextStyle(color: Colors.grey))),
                  ],
                ),
                const Divider(color: Colors.white10),
                ...List.generate(teams.length, (index) {
                  final team = teams[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            team[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: Text(
                            team[1],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: Text(
                            team[2],
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}