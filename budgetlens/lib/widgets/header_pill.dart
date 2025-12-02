import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class HeaderPill extends StatelessWidget {
  const HeaderPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            shape: const StadiumBorder(),
            side: BorderSide(color: colorScheme.secondaryContainer, width: 2),
          ),
          onPressed: () {
            budgetProvider.switchMode();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budgetProvider.state.viewMode ? 'For Today:' : 'Total Left:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                '₹${budgetProvider.projectedDisplayAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
