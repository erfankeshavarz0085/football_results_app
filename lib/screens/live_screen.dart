import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fixture_model.dart';
import '../providers/fixture_provider.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<FixtureProvider>(context, listen: false).loadLiveFixtures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Live Matches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: provider.loadLiveFixtures,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadLiveFixtures,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _liveHeader(),
            const SizedBox(height: 20),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                ),
              )
            else if (provider.errorMessage != null)
              _messageBox('خطا در دریافت مسابقات زنده')
            else if (provider.liveFixtures.isEmpty)
              _messageBox('در حال حاضر مسابقه زنده‌ای وجود ندارد')
            else
              ...provider.liveFixtures.map((fixture) {
                return _liveFixtureCard(fixture);
              }),
          ],
        ),
      ),
    );
  }

  Widget _liveHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.sports_soccer, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Live football matches are updated in real time.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBox(String text) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _liveFixtureCard(FixtureModel fixture) {
    final homeScore = fixture.homeScore?.toString() ?? '-';
    final awayScore = fixture.awayScore?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fixture.leagueName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fixture.status == '1H' || fixture.status == '2H'
                      ? 'LIVE'
                      : fixture.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _teamInfo(fixture.homeTeam, fixture.homeLogo)),
              Text(
                '$homeScore - $awayScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(child: _teamInfo(fixture.awayTeam, fixture.awayLogo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamInfo(String name, String logo) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: logo,
          width: 44,
          height: 44,
          placeholder: (_, __) =>
              const CircularProgressIndicator(strokeWidth: 2),
          errorWidget: (_, __, ___) => const Icon(
            Icons.shield_rounded,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}