import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/player_profile_model.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';
import '../widgets/empty_state_card.dart';

class PlayerDetailsScreen extends StatefulWidget {
  final PlayerProfileModel player;

  const PlayerDetailsScreen({super.key, required this.player});

  @override
  State<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<PlayerDetailsModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    _detailsFuture = _apiService.getPlayerDetails(widget.player);
  }

  void _retry() {
    setState(_loadDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(title: const Text('Player Details')),
      body: FutureBuilder<PlayerDetailsModel?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EmptyStateCard(
                  icon: Icons.cloud_off_rounded,
                  title: 'Player details unavailable',
                  message: ErrorMessages.fromException(snapshot.error!),
                  accentColor: Colors.redAccent,
                  actionLabel: 'Retry',
                  onAction: _retry,
                ),
              ],
            );
          }

          final details = snapshot.data;
          if (details == null) {
            return const Center(child: Text('Player not found'));
          }
          return _details(details);
        },
      ),
    );
  }

  Widget _details(PlayerDetailsModel details) {
    final player = details.profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _profileHeader(player),
        const SizedBox(height: 16),
        _personalInfo(player),
        const SizedBox(height: 24),
        _sectionTitle('Club Career', Icons.timeline_rounded),
        const SizedBox(height: 10),
        if (details.career.isEmpty)
          _emptySection('No club history is available.')
        else
          ...details.career.map(_careerCard),
        const SizedBox(height: 20),
        _sectionTitle(
          'Honours (${details.winnerCount} wins)',
          Icons.emoji_events_rounded,
        ),
        const SizedBox(height: 10),
        if (details.trophies.isEmpty)
          _emptySection('No honours are available.')
        else
          ...details.trophies.map(_trophyCard),
      ],
    );
  }

  Widget _profileHeader(PlayerProfileModel player) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xff0d1117),
              borderRadius: BorderRadius.circular(24),
            ),
            child:
                player.photo.isEmpty
                    ? const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.greenAccent,
                    )
                    : CachedNetworkImage(
                      imageUrl: player.photo,
                      fit: BoxFit.cover,
                      errorWidget:
                          (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.greenAccent,
                          ),
                    ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  [
                    player.nationality,
                    player.position,
                  ].where((value) => value.isNotEmpty).join(' - '),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalInfo(PlayerProfileModel player) {
    final birthPlace = [
      player.birthPlace,
      player.birthCountry,
    ].where((value) => value.isNotEmpty).join(', ');
    final items = <(String, String)>[
      ('Age', player.age?.toString() ?? '-'),
      ('Height', player.height.isEmpty ? '-' : player.height),
      ('Weight', player.weight.isEmpty ? '-' : player.weight),
      ('Birth date', player.birthDate.isEmpty ? '-' : player.birthDate),
      ('Birth place', birthPlace.isEmpty ? '-' : birthPlace),
      ('Number', player.number?.toString() ?? '-'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        children:
            items.map((item) {
              return SizedBox(
                width: (MediaQuery.sizeOf(context).width - 68) / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _careerCard(PlayerCareerSpan career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _imageBox(career.teamLogo, Icons.shield_rounded),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              career.teamName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            career.label,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trophyCard(PlayerTrophyModel trophy) {
    final isWinner = trophy.place.toLowerCase() == 'winner';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(
            isWinner ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
            color: isWinner ? Colors.amber : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trophy.league,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Team: ${trophy.teamName.isEmpty ? 'Unknown' : trophy.teamName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    trophy.country,
                    trophy.season,
                  ].where((value) => value.isNotEmpty).join(' - '),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            trophy.place,
            style: TextStyle(
              color: isWinner ? Colors.amber : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _emptySection(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _imageBox(String url, IconData fallback) {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          url.isEmpty
              ? Icon(fallback, color: Colors.black54)
              : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => Icon(fallback),
              ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xff161b22),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
    );
  }
}
