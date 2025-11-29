import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class HeaderPill extends StatelessWidget {
  const HeaderPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        return FilterChip(
          label: Text(
            budgetProvider.state.viewMode
                ? 'For Today: ₹${budgetProvider.displayAmount.toStringAsFixed(2)}'
                : 'Total Left: ₹${budgetProvider.displayAmount.toStringAsFixed(2)}',
          ),
          backgroundColor: budgetProvider.state.viewMode
              ? Colors.green
              : Colors.purple,
          onSelected: (bool selected) {
            budgetProvider.switchMode();
          },
        );
      },
    );
  }
}
