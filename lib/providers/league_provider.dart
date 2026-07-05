import 'package:flutter/material.dart';

class LeagueProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
}