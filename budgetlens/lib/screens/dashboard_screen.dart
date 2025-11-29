import 'package:flutter/material.dart';
import '../widgets/display_amount.dart';
import '../widgets/header_pill.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const HeaderPill(),
            ),
            const SizedBox(height: 20),
            const DisplayAmount(),
          ],
        ),
      ),
    );
  }
}