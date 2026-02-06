import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionDialog({super.key, required this.transaction});

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late TextEditingController _amountController;
  late TextEditingController _tagController;
  late DateTime _selectedDate;
  late CategoryType _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.abs().toString(),
    );
    _tagController = TextEditingController(text: widget.transaction.tag);
    _selectedDate = widget.transaction.datetime;
    _selectedCategory = widget.transaction.categoryType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.amount < 0;

    return AlertDialog(
      title: const Text('Edit Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amount
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),

            // Tag
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: 'Tag / Remark'),
            ),
            const SizedBox(height: 16),

            // Category (Only for Expenses)
            if (!isIncome)
              DropdownButtonFormField<CategoryType>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: CategoryType.needs,
                    child: Text('Needs (50%)'),
                  ),
                  DropdownMenuItem(
                    value: CategoryType.wants,
                    child: Text('Wants (30%)'),
                  ),
                  // Savings is usually auto-income, but user might manually categorize expense as savings?
                  // For now, let's keep it simple.
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),

            if (isIncome)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text("Income is automatically categorized as Savings."),
              ),

            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                  ),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Change')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final double? amount = double.tryParse(_amountController.text);
            if (amount == null) return;

            final finalAmount = isIncome ? -amount.abs() : amount.abs();

            final updatedTransaction = Transaction(
              finalAmount,
              _tagController.text.trim(),
              _selectedDate,
              categoryType: isIncome ? CategoryType.savings : _selectedCategory,
              id: widget.transaction.id,
            );

            Navigator.pop(context, updatedTransaction);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
