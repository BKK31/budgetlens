import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import '../models.dart';

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
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
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
                  '${transaction.datetime.toLocal().toString().split(' ')[0]}\n${transaction.datetime.toLocal().toString().split(' ')[1].split('.')[0]}',
                  textAlign: TextAlign.right,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
