import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Transactions'),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final transactions = budgetProvider.transactions.reversed.toList();
          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions yet.'),
            );
          }

          final grouped = groupTransactionsByMonth(transactions);
          return ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final month = grouped.keys.elementAt(index);
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
              final isExpense = transaction.amount > 0;
              return ListTile(
                leading: isExpense
                    ? const Icon(Icons.arrow_upward, color: Colors.red)
                    : const Icon(Icons.arrow_downward, color: Colors.green),
                title: Text(
                  '₹${transaction.amount.abs().toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(transaction.tag),
                trailing: Text(
                  '${transaction.datetime.day}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Add grouping transactions by Month
  Map<String, List<Transaciton>> groupTransactionsByMonth(List<Transaction> transactions) {
    final Map<String, List<Transaciton>> grouped = {};

    for(var transaction in transactions){
      final date = transaction.datetime;
      final key = '${_getMonthName(date.month)
      } ${date.year}';

      if(!grouped.containsKey(key)){
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }
    return grouped;
  }

  String _getMonthName(int month){
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return months[month - 1];
  }
}
