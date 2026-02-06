import 'package:budgetlens/screens/settings_screen.dart';
import 'package:budgetlens/screens/analysis_screen.dart';
import 'package:budgetlens/widgets/numpad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import '../widgets/display_amount.dart';
import '../widgets/header_pill.dart';
import '../widgets/expiration_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check for expiration after the build is done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BudgetProvider>(context, listen: false);
      if (provider.isBudgetExpired) {
        showDialog(
          context: context,
          barrierDismissible: false, // User must choose an option
          builder: (context) => const ExpirationDialog(),
        );
      }
    });
  }

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
                          builder: (context) => const AnalysisScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.pie_chart),
                    iconSize: 40,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
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
