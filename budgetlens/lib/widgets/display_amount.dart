import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class DisplayAmount extends StatelessWidget {
  const DisplayAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final amount = budgetProvider.projectedDisplayAmount;
        final currencySymbol = budgetProvider.currencySymbol;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currencySymbol${amount.toStringAsFixed(2).replaceAll(RegExp(r"\.?0+$"), "")}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                budgetProvider.state.viewMode
                    ? 'DAILY BUDGET'
                    : 'OVERALL BUDGET',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
