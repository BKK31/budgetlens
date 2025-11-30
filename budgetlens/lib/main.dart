import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'build_provider.dart';
import 'screens/dashboard_screen.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';

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
          child: MaterialApp(
            title: 'BudgetLens',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: const DashboardScreen(),
          ),
        );
      },
    );
  }
}