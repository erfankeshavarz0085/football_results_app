import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> leagueInfo;

  const OverviewTab({
    super.key,
    required this.leagueInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          title: 'League Overview',
          children: [
            _row('Competition', leagueInfo['name']),
            _row('Country', leagueInfo['country']),
            _row('Season', leagueInfo['season']),
            _row('League ID', leagueInfo['id'].toString()),
          ],
        ),
        const SizedBox(height: 14),
        _infoCard(
          title: 'Coming Next',
          children: const [
            Text(
              'Fixtures, standings, champions history and statistics will be added here.',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}