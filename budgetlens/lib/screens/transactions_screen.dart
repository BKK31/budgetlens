import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import '../models.dart';
import '../widgets/edit_transaction_dialog.dart';

class TransactionsScreen extends StatelessWidget {
  final CategoryType? filter;
  const TransactionsScreen({super.key, this.filter});

  @override
  Widget build(BuildContext context) {
    String title = 'Transactions';
    if (filter != null) {
      title =
          '${filter!.name[0].toUpperCase()}${filter!.name.substring(1)} Transactions';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          var transactions = budgetProvider.transactions.reversed.toList();

          if (filter != null) {
            transactions = transactions
                .where((t) => t.categoryType == filter)
                .toList();
          }

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          final grouped = groupTransactionsByMonth(transactions);
          return ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final monthKey = grouped.keys.elementAt(index);
              final monthTransactions = grouped[monthKey]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      monthKey,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...monthTransactions.map((transaction) {
                    return _buildTransactionItem(
                      context,
                      transaction,
                      budgetProvider,
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction transaction,
    BudgetProvider provider,
  ) {
    final isIncome = transaction.amount < 0;

    // Use theme-aware colors
    // Income is green (often legible on dark), Expense follows text theme
    Color amountColor = isIncome
        ? Colors.green
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    String sign = isIncome ? '+' : '';

    return InkWell(
      onTap: () => _showOptions(context, transaction, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Amount
            Text(
              '$sign${provider.currencySymbol}${transaction.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const SizedBox(height: 4),
            // Row 2: Metadata tags
            Row(
              children: [
                _buildCategoryBadge(transaction.categoryType, context),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaction.tag,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('MMM d, h:mm a').format(transaction.datetime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(CategoryType type, BuildContext context) {
    Color color;
    String label;

    switch (type) {
      case CategoryType.needs:
        color = Colors.blue.shade100;
        label = 'Needs';
        break;
      case CategoryType.wants:
        color = Colors.orange.shade100;
        label = 'Wants';
        break;
      case CategoryType.savings:
        color = Colors.green.shade100;
        label = 'Savings';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87, // Force dark text on light pastel background
        ),
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    Transaction transaction,
    BudgetProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final updated = await showDialog<Transaction>(
                    context: context,
                    builder: (context) =>
                        EditTransactionDialog(transaction: transaction),
                  );
                  if (updated != null) {
                    provider.updateTransaction(updated);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, transaction, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    Transaction transaction,
    BudgetProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text(
          'Are you sure you want to delete "${transaction.tag}" of ${provider.currencySymbol}${transaction.amount.abs()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(transaction.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Grouping logic
  Map<String, List<Transaction>> groupTransactionsByMonth(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
      final date = transaction.datetime;
      final key = '${_getMonthName(date.month)} ${date.year}';

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }
    return grouped;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
