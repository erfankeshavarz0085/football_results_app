import 'package:flutter/material.dart';

import 'league_details/league_details_screen.dart';

class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({super.key});

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  String searchQuery = '';

  final List<Map<String, dynamic>> leagues = const [
    {
      'id': 39,
      'name': 'Premier League',
      'country': 'England',
      'icon': Icons.sports_soccer,
    },
    {
      'id': 140,
      'name': 'La Liga',
      'country': 'Spain',
      'icon': Icons.sports_soccer,
    },
    {
      'id': 135,
      'name': 'Serie A',
      'country': 'Italy',
      'icon': Icons.sports_soccer,
    },
    {
      'id': 78,
      'name': 'Bundesliga',
      'country': 'Germany',
      'icon': Icons.sports_soccer,
    },
    {
      'id': 61,
      'name': 'Ligue 1',
      'country': 'France',
      'icon': Icons.sports_soccer,
    },
    {
      'id': 2,
      'name': 'Champions League',
      'country': 'Europe',
      'icon': Icons.emoji_events_rounded,
    },
    {
      'id': 1,
      'name': 'World Cup',
      'country': 'International',
      'icon': Icons.public_rounded,
    },
  ];

  List<Map<String, dynamic>> get filteredLeagues {
    if (searchQuery.trim().isEmpty) return leagues;

    final query = searchQuery.toLowerCase().trim();

    return leagues.where((league) {
      final name = league['name'].toString().toLowerCase();
      final country = league['country'].toString().toLowerCase();

      return name.contains(query) || country.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredLeagues;

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _topHeader(),
            const SizedBox(height: 16),
            _searchBox(),
            const SizedBox(height: 22),
            _sectionHeader(data.length),
            const SizedBox(height: 12),
            if (data.isEmpty)
              _emptyBox()
            else
              ...data.map((league) => _leagueCard(context, league)),
          ],
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff132015),
            Color(0xff111827),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.greenAccent,
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leagues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Browse competitions, fixtures and standings',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search leagues or countries...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.greenAccent),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xff161b22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Top Competitions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '$count leagues',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _leagueCard(BuildContext context, Map<String, dynamic> league) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xff0d1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(
            league['icon'] as IconData,
            color: Colors.greenAccent,
          ),
        ),
        title: Text(
          league['name'].toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            league['country'].toString(),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Favorites will be added in the next step'),
                  ),
                );
              },
              icon: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.grey,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.greenAccent,
              size: 16,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LeagueDetailsScreen(
                leagueId: league['id'] as int,
                leagueName: league['name'].toString(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Text(
          'No leagues found',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}