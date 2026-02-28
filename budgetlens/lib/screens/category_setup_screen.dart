import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../build_provider.dart';
import '../models.dart';

class CategorySetupScreen extends StatefulWidget {
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final String currencyCode;

  const CategorySetupScreen({
    super.key,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.currencyCode,
  });

  @override
  State<CategorySetupScreen> createState() => _CategorySetupScreenState();
}

class _CategorySetupScreenState extends State<CategorySetupScreen> {
  bool isCustomStrategy = false;
  List<CustomCategory> categories = [];

  @override
  void initState() {
    super.initState();
    // Initialize with default custom mapping for user to edit if they choose
    categories = [
      CustomCategory(
        id: const Uuid().v4(),
        name: 'Needs',
        percentage: 50,
        isSavings: false,
      ),
      CustomCategory(
        id: const Uuid().v4(),
        name: 'Wants',
        percentage: 30,
        isSavings: false,
      ),
      CustomCategory(
        id: const Uuid().v4(),
        name: 'Savings',
        percentage: 20,
        isSavings: true,
      ),
    ];
  }

  double get totalPercentage {
    return categories
        .where((cat) => cat.amount == null)
        .fold(0.0, (sum, cat) => sum + cat.percentage);
  }

  double get totalFixedAmount {
    return categories
        .where((cat) => cat.amount != null)
        .fold(0.0, (sum, cat) => sum + cat.amount!);
  }

  double get totalAllocation {
    return totalFixedAmount + (widget.budget * (totalPercentage / 100.0));
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double value = 0;
        bool isFixedAmount = false;
        bool isSavings = false;
        final valueController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double currentAllocation = totalAllocation;
            double remaining = widget.budget - currentAllocation;
            // The remaining percentage should be based on the actual remaining budget
            double remainingPercent = widget.budget > 0
                ? (remaining / widget.budget * 100)
                : 0;

            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (val) => name = val,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                            labelText: isFixedAmount ? 'Amount' : 'Percentage',
                            prefixText: isFixedAmount
                                ? widget.currencyCode + ' '
                                : null,
                            suffixText: isFixedAmount ? null : '%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) => value = double.tryParse(val) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setStateDialog(() {
                            if (isFixedAmount) {
                              value = remaining > 0 ? remaining : 0;
                            } else {
                              value = remainingPercent > 0
                                  ? remainingPercent
                                  : 0;
                            }
                            valueController.text = value
                                .toStringAsFixed(2)
                                .replaceAll(RegExp(r'\.?0+$'), '');
                          });
                        },
                        child: const Text(
                          'Remaining',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fixed Amount?'),
                      Switch(
                        value: isFixedAmount,
                        onChanged: (val) {
                          setStateDialog(() {
                            isFixedAmount = val;
                            value = 0;
                            valueController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    title: const Text('Is Savings?'),
                    value: isSavings,
                    onChanged: (val) {
                      setStateDialog(() {
                        isSavings = val ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (name.isNotEmpty && value > 0) {
                      setState(() {
                        categories.add(
                          CustomCategory(
                            id: const Uuid().v4(),
                            name: name,
                            percentage: isFixedAmount ? 0 : value,
                            amount: isFixedAmount ? value : null,
                            isSavings: isSavings,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _finishSetup() async {
    final tolerance = 0.05; // Slightly larger tolerance for floating point
    double allocation = totalAllocation;
    if (isCustomStrategy && (allocation - widget.budget).abs() > tolerance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Total allocation (${allocation.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}) must match budget (${widget.budget.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')})',
          ),
        ),
      );
      return;
    }

    await Provider.of<BudgetProvider>(context, listen: false).saveBudgetSetup(
      widget.budget,
      widget.startDate,
      widget.endDate,
      currencyCode: widget.currencyCode,
      isCustomStrategy: isCustomStrategy,
      categories: isCustomStrategy ? categories : null,
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Strategy')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioListTile<bool>(
                title: const Text('Default Plan (50/30/20)'),
                subtitle: const Text('50% Needs, 30% Wants, 20% Savings'),
                value: false,
                groupValue: isCustomStrategy,
                onChanged: (val) {
                  setState(() => isCustomStrategy = val!);
                },
              ),
              RadioListTile<bool>(
                title: const Text('Custom Strategy'),
                subtitle: const Text('Create your own categories & amounts'),
                value: true,
                groupValue: isCustomStrategy,
                onChanged: (val) {
                  setState(() => isCustomStrategy = val!);
                },
              ),
              if (isCustomStrategy) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total: ${totalAllocation.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} / ${widget.budget.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}',
                          style: TextStyle(
                            color:
                                (totalAllocation - widget.budget).abs() < 0.01
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((totalAllocation - widget.budget).abs() >= 0.01)
                          Text(
                            'Remaining: ${(widget.budget - totalAllocation).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      double calculatedPercent = cat.amount != null
                          ? (cat.amount! / widget.budget * 100)
                          : cat.percentage;
                      String displayValue = cat.amount != null
                          ? '${widget.currencyCode} ${cat.amount!.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} (${calculatedPercent.toStringAsFixed(1)}%)'
                          : '${cat.percentage.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}%';
                      return ListTile(
                        title: Text(cat.name),
                        subtitle: Text(
                          '$displayValue ${cat.isSavings ? "(Savings)" : "(Expense)"}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              categories.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    onPressed: _addCategory,
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _finishSetup,
                  child: const Text('Complete Setup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
