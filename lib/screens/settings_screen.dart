import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 18),
          _settingSwitch(
            icon: Icons.favorite_rounded,
            title: 'Favorites summary on Home',
            subtitle: 'Show saved teams, leagues and matches on the home page.',
            value: settings.showFavoritesOnHome,
            onChanged: settings.setShowFavoritesOnHome,
          ),
          _settingSwitch(
            icon: Icons.history_rounded,
            title: 'Recently viewed in Search',
            subtitle: 'Show recently opened teams, leagues and matches.',
            value: settings.showRecentlyViewedInSearch,
            onChanged: settings.setShowRecentlyViewedInSearch,
          ),
          _settingSwitch(
            icon: Icons.notifications_active_rounded,
            title: 'Match alert controls',
            subtitle: 'Show Kickoff, Goals and Full time alert preferences.',
            value: settings.showMatchAlertControls,
            onChanged: settings.setShowMatchAlertControls,
          ),
        ],
      ),
    );
  }

  Widget _header() {
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
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.tune_rounded, color: Colors.black),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Personalize the way Shoot Ball shows saved content and alerts.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, height: 1.35),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.greenAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
