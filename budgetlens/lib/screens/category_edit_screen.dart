import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import '../build_provider.dart';
import '../models.dart';
import '../widgets/category_badge.dart';

class CategoryEditScreen extends StatefulWidget {
  const CategoryEditScreen({super.key});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  bool isCustomStrategy = false;
  List<CustomCategory> categories = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = context.read<BudgetProvider>();
      isCustomStrategy = provider.state.isCustomStrategy;
      if (isCustomStrategy) {
        categories = provider.state.categories
            .map(
              (c) => CustomCategory(
                id: c.id,
                name: c.name,
                percentage: c.percentage,
                amount: c.amount,
                isSavings: c.isSavings,
                colorValue: c.colorValue,
              ),
            )
            .toList();
      } else {
        // Initialize with default mapping for user to edit if they switch to custom
        categories = [
          CustomCategory(
            id: const Uuid().v4(),
            name: 'Needs',
            percentage: 50,
            isSavings: false,
            colorValue: 0xFF2196F3,
          ),
          CustomCategory(
            id: const Uuid().v4(),
            name: 'Wants',
            percentage: 30,
            isSavings: false,
            colorValue: 0xFFFF9800,
          ),
          CustomCategory(
            id: const Uuid().v4(),
            name: 'Savings',
            percentage: 20,
            isSavings: true,
            colorValue: 0xFF4CAF50,
          ),
        ];
      }
      _initialized = true;
    }
  }

  double get budget => context.read<BudgetProvider>().state.totalBudget;
  String get currencyCode => context.read<BudgetProvider>().state.currencyCode;

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
    return totalFixedAmount + (budget * (totalPercentage / 100.0));
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double value = 0;
        bool isFixedAmount = false;
        bool isSavings = false;
        int colorValue = 0xFF2196F3;
        final valueController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double currentAllocation = totalAllocation;
            double remaining = budget - currentAllocation;
            double remainingPercent = budget > 0
                ? (remaining / budget * 100)
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
                            prefixText: isFixedAmount ? '$currencyCode ' : null,
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
                        if (isSavings) {
                          colorValue = 0xFF4CAF50; // Green for savings
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Color:'),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pick a color'),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: Color(colorValue),
                                  onColorChanged: (color) {
                                    setStateDialog(() {
                                      colorValue = color.value;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
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
                            colorValue: colorValue,
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

  Future<void> _saveChanges() async {
    final tolerance = 0.05;
    double allocation = totalAllocation;
    if (isCustomStrategy && (allocation - budget).abs() > tolerance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Total allocation (${allocation.toStringAsFixed(2)}) must match budget (${budget.toStringAsFixed(2)})',
          ),
        ),
      );
      return;
    }

    await context.read<BudgetProvider>().updateCategories(
      isCustomStrategy: isCustomStrategy,
      categories: isCustomStrategy ? categories : null,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Strategy updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Budget Strategy')),
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
                          'Total: ${totalAllocation.toStringAsFixed(2)} / ${budget.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: (totalAllocation - budget).abs() < 0.01
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((totalAllocation - budget).abs() >= 0.01)
                          Text(
                            'Remaining: ${(budget - totalAllocation).toStringAsFixed(2)}',
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
                          ? (cat.amount! / budget * 100)
                          : cat.percentage;
                      String displayValue = cat.amount != null
                          ? '$currencyCode ${cat.amount!.toStringAsFixed(2)} (${calculatedPercent.toStringAsFixed(1)}%)'
                          : '${cat.percentage.toStringAsFixed(2)}%';
                      return ListTile(
                        title: CategoryBadge(
                          label: cat.name,
                          color: Color(cat.colorValue),
                          fontSize: 16,
                        ),
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
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
