import 'package:budgetlens/widgets/numpad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import 'transactions_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:restart_app/restart_app.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showEditBudgetDialog(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final TextEditingController budgetController = TextEditingController(
      text: budgetProvider.state.totalBudget.toString(),
    );
    DateTime? selectedEndDate = budgetProvider.state.budgetEndDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Edit Budget'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Budget Amount',
                          hintText: budgetProvider.state.totalBudget.toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        title: Text(
                          selectedEndDate == null
                              ? 'Select End Date'
                              : 'End Date: ${selectedEndDate.toString().split(' ')[0]}',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedEndDate ?? DateTime.now(),
                            firstDate: budgetProvider.state.budgetStartDate,
                            lastDate: budgetProvider.state.budgetStartDate.add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedEndDate = picked;
                            });
                          }
                        },
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                if (budgetController.text.isEmpty ||
                                    selectedEndDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                  return;
                                }

                                double newBudget = double.parse(
                                  budgetController.text,
                                );

                                await budgetProvider.updateBudgetSetup(
                                  newBudget,
                                  budgetProvider.state.budgetStartDate,
                                  selectedEndDate!,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Budget updated!'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

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
                  // 1. Budget Summary Sheet
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
                                'Budget Summary',
                                style: textTheme.titleLarge,
                              ),
                              const Spacer(),
                              IconButton.filledTonal(
                                onPressed: () {
                                  _showEditBudgetDialog(
                                    context,
                                    budgetProvider,
                                  );
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${budgetProvider.state.totalBudget.toStringAsFixed(2)}',
                                          style: textTheme.headlineSmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSecondaryContainer,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28,
                                              ),
                                        ),
                                        Text(
                                          'Starting budget',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              budgetProvider
                                                  .state
                                                  .budgetStartDate
                                                  .toString()
                                                  .split(' ')[0],
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 14,
                                              color: colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                            Text(
                                              budgetProvider.state.budgetEndDate
                                                  .toString()
                                                  .split(' ')[0],
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSecondaryContainer,
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
                                        value:
                                            budgetProvider.daysRemaining / 30,
                                        strokeWidth: 8,
                                        backgroundColor: colorScheme.primary
                                            .withAlpha(51),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          budgetProvider.daysRemaining
                                              .toString(),
                                          style: textTheme.headlineSmall
                                              ?.copyWith(
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
                          leading: const Icon(Icons.history),
                          title: Text(
                            'Past Transactions',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionsScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(
                            'Currency',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          trailing: Text(
                            'Indian Rupee (₹)',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.backup),
                          title: Text(
                            'Backup Data',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () async {
                            try {
                              final jsonString = await budgetProvider
                                  .createBackup();
                              final directory = await getTemporaryDirectory();
                              final file = File(
                                '${directory.path}/budget_lens_backup.json',
                              );
                              if (await file.exists()) {
                                await file.delete();
                              }
                              await file.writeAsString(jsonString, flush: true);
                              await Share.shareXFiles([
                                XFile(file.path),
                              ], text: 'Budget Lens Backup');
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error creating backup: $e'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: Text(
                            'Restore Data',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () async {
                            try {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['json'],
                                  );

                              if (result != null) {
                                File file = File(result.files.single.path!);
                                String jsonString = await file.readAsString();
                                await budgetProvider.restoreBackup(jsonString);

                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Restore Successful'),
                                      content: const Text(
                                        'App needs to restart to apply changes.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Restart.restartApp();
                                          },
                                          child: const Text('Restart Now'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error restoring backup: $e'),
                                  ),
                                );
                              }
                            }
                          },
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
