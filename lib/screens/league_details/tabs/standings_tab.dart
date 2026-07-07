import 'package:flutter/material.dart';

class StandingsTab extends StatelessWidget {
  final int leagueId;
  final String leagueName;

  const StandingsTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'League standings will be added here.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}