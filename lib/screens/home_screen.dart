import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Football Results'),
      ),
      body: Center(
        child: Text('Home Screen آماده است'),
      ),
    );
  }
}