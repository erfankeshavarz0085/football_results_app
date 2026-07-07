import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  final int leagueId;
  final String leagueName;

  const HistoryTab({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Previous champions history will be added here.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}