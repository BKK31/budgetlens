import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. "For Today" Chip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'For today',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '₹${budgetProvider.displayAmount.toStringAsFixed(2)}',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Budget Summary Sheet
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant.withAlpha(102),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              Text(
                                'Budget',
                                style: textTheme.titleLarge,
                              ),
                              const Spacer(),
                              IconButton.filledTonal(
                                onPressed: () {
                                  // TODO: Open edit dialog
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Large Remaining Budget Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            color: colorScheme.tertiaryContainer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Text(
                                      '₹${budgetProvider.remainingBudget.toStringAsFixed(2)}',
                                      style: textTheme.displaySmall?.copyWith(
                                        color: colorScheme.onTertiaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 48,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'Left',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4. Timeline and Days-Left Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              // 4a. Starting Budget Card
                              Expanded(
                                child: Card(
                                  color: colorScheme.secondaryContainer,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${budgetProvider.state.totalBudget.toStringAsFixed(2)}',
                                          style: textTheme.headlineSmall?.copyWith(
                                            color: colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        Text(
                                          'Starting budget',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              budgetProvider.state.budgetStartDate
                                                  .toString()
                                                  .split(' ')[0],
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSecondaryContainer,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 14,
                                              color: colorScheme.onSecondaryContainer,
                                            ),
                                            Text(
                                              budgetProvider.state.budgetEndDate
                                                  .toString()
                                                  .split(' ')[0],
                                              style: textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSecondaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // 4b. Days-Left Indicator
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CircularProgressIndicator(
                                        value: budgetProvider.daysRemaining / 30,
                                        strokeWidth: 8,
                                        backgroundColor:
                                            colorScheme.primary.withAlpha(51),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.primary),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          budgetProvider.daysRemaining.toString(),
                                          style: textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        Text(
                                          'Days left',
                                          style: textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 5. Settings Section
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(
                            'Currency',
                            style: textTheme.titleMedium?.copyWith(fontSize: 18),
                          ),
                          trailing: Text(
                            'Indian Rupee (₹)',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant),
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.download),
                          title: Text(
                            'Export to CSV',
                            style: textTheme.titleMedium?.copyWith(fontSize: 18),
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}