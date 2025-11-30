import 'package:budgetlens/screens/settings_screen.dart';
import 'package:budgetlens/widgets/numpad.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(child: const HeaderPill()),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    iconSize: 40,
                  ),
                ],
              ),
            ),
            const DisplayAmount(),
            const Spacer(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              child: const Numpad(),
            ),
          ],
        ),
      ),
    );
  }
}
