import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/fixture_model.dart';
import '../utils/constants.dart';

class ApiService {
  Map<String, String> get _headers => {
        'x-apisports-key': AppConstants.apiKey,
      };

  Future<List<FixtureModel>> getTodayFixtures() async {
    final now = DateTime.now();

    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?date=$date&timezone=Asia/Tehran',
    );

    return _fetchFixtures(url);
  }

  Future<List<FixtureModel>> getLiveFixtures() async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?live=all&timezone=Asia/Tehran',
    );

    return _fetchFixtures(url);
  }

  Future<List<FixtureModel>> getLeagueFixtures(int leagueId) async {
    final seasonsToTry = [2024];

    for (final season in seasonsToTry) {
      final url = Uri.parse(
        '${AppConstants.baseUrl}/fixtures?league=$leagueId&season=$season&timezone=Asia/Tehran',
      );

      final fixtures = await _fetchFixtures(url);

      debugPrint('League $leagueId season $season fixtures count: ${fixtures.length}');

      if (fixtures.isNotEmpty) {
        return fixtures;
      }
    }

    return [];
  }

  Future<List<FixtureModel>> getWorldCupFixtures() async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/fixtures?league=1&season=2026&timezone=Asia/Tehran',
    );

    return _fetchFixtures(url);
  }

  Future<List<FixtureModel>> _fetchFixtures(Uri url) async {
    try {
      debugPrint('API URL: $url');

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List fixtures = data['response'] ?? [];

        return fixtures.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API EXCEPTION: $e');
      throw Exception('خطا در دریافت اطلاعات: $e');
    }
  }
}