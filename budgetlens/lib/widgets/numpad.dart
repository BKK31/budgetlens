import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import '../models.dart';
import '../widgets/category_badge.dart';

class Numpad extends StatefulWidget {
  const Numpad({super.key});

  @override
  State<Numpad> createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  String _currentInput = '';
  bool _isIncome = false;

  void _handleTap(String value) {
    setState(() {
      if (_currentInput == '0' && value != '.') {
        _currentInput = value;
      } else {
        _currentInput += value;
      }
    });
    _updatePreview();
  }

  void _handleBackspace() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
      _updatePreview();
    }
  }

  void _toggleSign() {
    setState(() {
      _isIncome = !_isIncome;
    });
    _updatePreview();
  }

  void _updatePreview() {
    final amount = double.tryParse(_currentInput) ?? 0.0;
    context.read<BudgetProvider>().updatePreview(amount, _isIncome);
  }

  void _handleConfirm(BudgetProvider budgetProvider) {
    if (_currentInput.isEmpty) return;
    double? amount = double.tryParse(_currentInput);
    if (amount == null) return;

    if (budgetProvider.state.isCustomStrategy) {
      // Custom Strategy -> Select from Custom Categories for BOTH income and expense
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              _isIncome ? 'Select Category for Income' : 'Select Category',
            ),
            children: budgetProvider.state.categories.map((cat) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _showTagDialog(
                    budgetProvider,
                    _isIncome ? -amount : amount,
                    categoryId: cat.id,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CategoryBadge(
                    label: '${cat.name} (${cat.percentage}%)',
                    color: Color(cat.colorValue),
                    fontSize: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      );
    } else {
      // Legacy 50/30/20 Strategy
      if (_isIncome) {
        // Income -> Automatically Savings.
        _showTagDialog(
          budgetProvider,
          -amount,
          categoryType: CategoryType.savings,
        );
      } else {
        // Legacy Expense -> Select Needs or Wants
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Select Category'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    _showTagDialog(
                      budgetProvider,
                      amount,
                      categoryType: CategoryType.needs,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Needs (50%)', style: TextStyle(fontSize: 18)),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    _showTagDialog(
                      budgetProvider,
                      amount,
                      categoryType: CategoryType.wants,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Wants (30%)', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showTagDialog(
    BudgetProvider budgetProvider,
    double amount, {
    CategoryType categoryType = CategoryType.needs,
    String? categoryId,
  }) {
    String selectedSubCategory = budgetProvider.state.subCategories.first;
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Transaction Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedSubCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: budgetProvider.state.subCategories.map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            selectedSubCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Remarks',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: remarksController,
                      decoration: const InputDecoration(
                        hintText: "Add details here...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String remarks = remarksController.text.trim();

                    budgetProvider.recordTransaction(
                      amount,
                      selectedSubCategory, // Using subCategory as the 'tag' for legacy compatibility where needed
                      subCategory: selectedSubCategory,
                      remarks: remarks,
                      categoryType: categoryType,
                      categoryId: categoryId,
                    );

                    budgetProvider.updatePreview(0, false);
                    setState(() {
                      _currentInput = '';
                      _isIncome = false;
                    });
                    Navigator.of(dialogContext).pop();

                    // Feedback
                    if (categoryId != null) {
                      final cat = budgetProvider.state.categories.firstWhere(
                        (c) => c.id == categoryId,
                        orElse: () => CustomCategory(
                          id: '',
                          name: 'Selected Category',
                          percentage: 0,
                          colorValue: 0xFF2196F3,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to ${cat.name}')),
                      );
                    } else if (categoryType == CategoryType.savings) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Savings (20%)')),
                      );
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          alignment: Alignment.centerRight,
          child: Text(
            '${_isIncome ? ' ' : ''}${context.read<BudgetProvider>().currencySymbol}${_currentInput.isEmpty ? '0' : _currentInput}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _isIncome ? Colors.green : colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Numpad
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Number grid (7, 8, 9, 4, 5, 6, 1, 2, 3, 0, .)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildNumberRow(['7', '8', '9']),
                      _buildNumberRow(['4', '5', '6']),
                      _buildNumberRow(['1', '2', '3']),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _NumpadButton(
                                text: '0',
                                onPressed: () => _handleTap('0'),
                              ),
                            ),
                            Expanded(
                              child: _NumpadButton(
                                text: '.',
                                onPressed: () {
                                  if (!_currentInput.contains('.')) {
                                    _handleTap('.');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Operations column (backspace, minus, check)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: _NumpadButton(
                          icon: Icons.backspace_outlined,
                          onPressed: _handleBackspace,
                          color: colorScheme.tertiary,
                        ),
                      ),
                      Expanded(
                        child: _NumpadButton(
                          text: 'i',
                          onPressed: _toggleSign,
                          color: colorScheme.tertiary,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _NumpadButton(
                          icon: Icons.check,
                          onPressed: () =>
                              _handleConfirm(context.read<BudgetProvider>()),
                          color: colorScheme.primary,
                          isElevated: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Expanded(
      child: Row(
        children: numbers
            .map(
              (number) => Expanded(
                child: _NumpadButton(
                  text: number,
                  onPressed: () => _handleTap(number),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isElevated;

  const _NumpadButton({
    this.text,
    this.icon,
    required this.onPressed,
    this.color,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonStyle = ButtonStyle(
      shape: WidgetStateProperty.all(const StadiumBorder()),
      padding: WidgetStateProperty.all(const EdgeInsets.all(16.0)),
      backgroundColor: WidgetStateProperty.all(
        isElevated
            ? color
            : (color?.withOpacity(0.1) ?? colorScheme.secondaryContainer),
      ),
      foregroundColor: WidgetStateProperty.all(
        isElevated ? colorScheme.onPrimary : color ?? colorScheme.onSurface,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Icon(icon, size: 24),
        ),
      ),
    );
  }
}
