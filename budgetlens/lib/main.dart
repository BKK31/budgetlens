import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'build_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ChangeNotifierProvider(
          create: (context) => BudgetProvider(),
          builder: (context, child) {
            return MaterialApp(
              title: 'BudgetLens',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme:
                    lightDynamic ??
                    ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme:
                    darkDynamic ??
                    ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              home: const _HomeScreen(),
            );
          },
        );
      },
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: () async {
        await context.read<BudgetProvider>().loadSavedBudget();
        await context.read<BudgetProvider>().debugCheckLaunch();
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return FutureBuilder<bool>(
          future: context.read<BudgetProvider>().isFirstLaunch(),
          builder: (context, launchSnapshot) {
            if (launchSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return launchSnapshot.data == true
                ? const SetupScreen()
                : const DashboardScreen();
          },
        );
      },
    );
  }
}
