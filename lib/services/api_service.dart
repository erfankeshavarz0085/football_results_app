import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/fixture_model.dart';
import '../utils/constants.dart';

class ApiService {
  Future<List<FixtureModel>> getTodayFixtures() async {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final url = Uri.parse('${AppConstants.baseUrl}/fixtures?date=$date');

    final response = await http.get(
      url,
      headers: {
        'x-apisports-key': AppConstants.apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List fixtures = data['response'];
      return fixtures.map((json) => FixtureModel.fromJson(json)).toList();
    } else {
      throw Exception('خطا در دریافت مسابقات امروز');
    }
  }

  Future<List<FixtureModel>> getLiveFixtures() async {
    final url = Uri.parse('${AppConstants.baseUrl}/fixtures?live=all');

    final response = await http.get(
      url,
      headers: {
        'x-apisports-key': AppConstants.apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List fixtures = data['response'];
      return fixtures.map((json) => FixtureModel.fromJson(json)).toList();
    } else {
      throw Exception('خطا در دریافت مسابقات زنده');
    }
  }
}