import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class DisplayAmount extends StatelessWidget {
  const DisplayAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
          return Center(
            child: 
            Padding(padding: const EdgeInsets.all(16.0))
          );
      },
    );
  }
}

