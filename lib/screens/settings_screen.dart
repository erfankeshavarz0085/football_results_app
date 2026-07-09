import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';
import '../utils/constants.dart';

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
          _apiStatusCard(settings),
          const SizedBox(height: 14),
          _settingSwitch(
            icon: Icons.offline_bolt_rounded,
            title: 'Demo fallback',
            subtitle:
                'Show sample football data when the real API is unavailable.',
            value: settings.demoFallbackEnabled,
            onChanged: settings.setDemoFallbackEnabled,
          ),
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

  Widget _apiStatusCard(AppSettingsProvider settings) {
    final apiEnabled = AppConstants.apiEnabled;
    final envDemoEnabled = AppConstants.demoFallbackEnabled;
    final demoEnabled = envDemoEnabled && settings.demoFallbackEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.api_rounded, color: Colors.greenAccent),
              SizedBox(width: 12),
              Text(
                'Data source',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _statusRow(
            'Real API',
            apiEnabled ? 'Enabled' : 'Disabled',
            apiEnabled ? Colors.greenAccent : Colors.redAccent,
          ),
          _statusRow(
            'Demo fallback',
            demoEnabled ? 'Enabled' : 'Disabled',
            demoEnabled ? Colors.greenAccent : Colors.redAccent,
          ),
          if (!envDemoEnabled) ...[
            const SizedBox(height: 8),
            const Text(
              'Demo fallback is disabled in .env.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
