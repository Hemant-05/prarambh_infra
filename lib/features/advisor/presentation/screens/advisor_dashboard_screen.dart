import 'package:flutter/material.dart';

class AdvisorDashboardScreen extends StatelessWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advisor Dashboard')),
      body: const Center(child: Text('Welcome, Advisor!')),
    );
  }
}
