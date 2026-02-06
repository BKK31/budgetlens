import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late TextEditingController budgetController;
  late DateTime selectedStartDate;
  DateTime? selectedEndDate;
  String _selectedCurrencyCode = 'INR';

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
  };

  @override
  void initState() {
    super.initState();
    budgetController = TextEditingController();
    selectedStartDate = DateTime.now();
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Currency'),
          children: _currencySymbols.keys.map((currencyCode) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCurrencyCode = currencyCode;
                });
                Navigator.pop(context);
              },
              child: Text('$currencyCode (${_currencySymbols[currencyCode]})'),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isBudgetValid =
        budgetController.text.isNotEmpty &&
        double.tryParse(budgetController.text) != null &&
        double.parse(budgetController.text) > 0;
    final bool isDateValid = selectedEndDate != null;
    final bool canApply = isBudgetValid && isDateValid;
    final String currencySymbol = _currencySymbols[_selectedCurrencyCode] ?? '';

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 32,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Setting up a budget',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Enter your budget',
                  hintText: '0',
                  border: const OutlineInputBorder(),
                  prefixText: '$currencySymbol ',
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  selectedEndDate == null
                      ? 'No finish date selected'
                      : 'Finish Date: ${selectedEndDate.toString().split(' ')[0]}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedEndDate ?? selectedStartDate,
                    firstDate: selectedStartDate,

                    lastDate: selectedStartDate.add(
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
              ListTile(
                leading: const Icon(Icons.currency_exchange_outlined),
                title: const Text('Currency'),
                trailing: Text('$_selectedCurrencyCode ($currencySymbol)'),
                onTap: _showCurrencyDialog,
              ),
              const Spacer(),
              if (!canApply)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unable to budget',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isBudgetValid)
                            Text(
                              'Enter your budget',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (!isDateValid)
                            Text(
                              'Calculate the budget for at least one day',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (budgetController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a budget amount')),
                      );
                      return;
                    }

                    if (selectedEndDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select an end date')),
                      );
                      return;
                    }

                    double budget = double.parse(budgetController.text);

                    // Wait for this to complete!
                    await Provider.of<BudgetProvider>(
                      context,
                      listen: false,
                    ).saveBudgetSetup(
                      budget,
                      selectedStartDate,
                      selectedEndDate!,
                    );

                    // Only navigate after it's saved
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
