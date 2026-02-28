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
    return categories.fold(0.0, (sum, cat) => sum + cat.percentage);
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double percentage = 0;
        bool isSavings = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (val) => name = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Percentage'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => percentage = double.tryParse(val) ?? 0,
                  ),
                  CheckboxListTile(
                    title: const Text('Is Savings?'),
                    value: isSavings,
                    onChanged: (val) {
                      setStateDialog(() {
                        isSavings = val ?? false;
                      });
                    },
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
                    if (name.isNotEmpty && percentage > 0) {
                      setState(() {
                        categories.add(
                          CustomCategory(
                            id: const Uuid().v4(),
                            name: name,
                            percentage: percentage,
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
    if (isCustomStrategy && totalPercentage != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total percentage must be exactly 100%')),
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
                subtitle: const Text(
                  'Create your own categories & percentages',
                ),
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
                    Text(
                      'Total: ${totalPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: totalPercentage == 100
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return ListTile(
                        title: Text(cat.name),
                        subtitle: Text(
                          '${cat.percentage}% ${cat.isSavings ? "(Savings)" : "(Expense)"}',
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
