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
            backgroundColor: budgetProvider.state.viewMode
                ? colorScheme.tertiaryContainer
                : colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            shape: const StadiumBorder(),
            side: BorderSide(color: colorScheme.secondaryContainer, width: 2),
          ),
          onPressed: () {
            budgetProvider.switchMode();
          },
          // child: Text(
          //   budgetProvider.state.viewMode
          //       ? 'For Today: ₹${budgetProvider.displayAmount.toStringAsFixed(2)}'
          //       : 'Total Left: ₹${budgetProvider.displayAmount.toStringAsFixed(2)}',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: 28,
          //     color: colorScheme.primary,
          //   ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budgetProvider.state.viewMode ? 'For Today:' : 'Total Left:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                '₹${budgetProvider.displayAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
