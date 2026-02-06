import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import '../screens/setup_screen.dart';

class ExpirationDialog extends StatefulWidget {
  const ExpirationDialog({super.key});

  @override
  State<ExpirationDialog> createState() => _ExpirationDialogState();
}

class _ExpirationDialogState extends State<ExpirationDialog> {
  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false, // Force user to make a choice
      child: AlertDialog(
        title: const Text('Budget Expired'),
        content: const Text(
          'Your budget end date has passed. What would you like to do?',
        ),
        actions: [
          // Option 1: Extend
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null && context.mounted) {
                await budgetProvider.extendBudget(picked);
                Navigator.pop(context);
              }
            },
            child: const Text('Extend'),
          ),

          // Option 2: Rollover
          TextButton(
            onPressed: () {
              _showRolloverDialog(context, budgetProvider);
            },
            child: const Text('Rollover'),
          ),

          // Option 3: New Budget
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SetupScreen()),
              );
            },
            child: const Text('New Budget'),
          ),
        ],
      ),
    );
  }

  void _showRolloverDialog(BuildContext context, BudgetProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rollover Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add extra amount to remaining balance (optional):'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Extra Amount',
                prefixText: '₹',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final extra = double.tryParse(controller.text) ?? 0.0;
              
              // Pick new end date
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );

              if (picked != null && context.mounted) {
                await provider.rolloverBudget(extra, picked);
                Navigator.pop(context); // Close rollover dialog
                Navigator.pop(context); // Close expiration dialog
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
