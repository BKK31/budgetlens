import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetlens/screens/transactions_screen.dart';
import '../models.dart';
import '../build_provider.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Analysis')),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          final state = provider.state;
          final totalBudget = state.totalBudget; // Base for 50/30/20

          final needsTarget = totalBudget * 0.50;
          final wantsTarget = totalBudget * 0.30;
          final savingsTarget = totalBudget * 0.20; // Minimum optimization

          final needsSpent = state.needsSpent;
          final wantsSpent = state.wantsSpent;

          // Savings = (Allocated 20%) + (Extra Income) - (Any "Savings" expenses? No, we don't spend from savings usually).
          // Actually, "Savings" in 50/30/20 is what you PUT ASIDE.
          // So Current Savings = (20% of Budget) + Total Income.
          // This represents how much has been "saved" or "allocated to savings" this month.
          // Unless the user explicitly "transfers" it out. We don't track transfers.
          // So we just show the Potential Savings.
          final totalSavings = savingsTarget + state.totalIncome;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCategoryCard(
                context,
                provider,
                title: 'Needs (50%)',
                spent: needsSpent,
                target: needsTarget,
                color: Colors.blue,
                icon: Icons.home,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TransactionsScreen(filter: CategoryType.needs),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                provider,
                title: 'Wants (30%)',
                spent: wantsSpent,
                target: wantsTarget,
                color: Colors.orange,
                icon: Icons.favorite,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TransactionsScreen(filter: CategoryType.wants),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSavingsCard(
                context,
                provider,
                title: 'Savings & Debt (20%)',
                amount: totalSavings,
                baseTarget: savingsTarget,
                extraIncome: state.totalIncome,
                color: Colors.green,
                icon: Icons.savings,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionsScreen(
                        filter: CategoryType.savings,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Note: Income transactions are automatically added to your Savings bucket.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    BudgetProvider provider, {
    required String title,
    required double spent,
    required double target,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final progress = target > 0 ? (spent / target) : 0.0;
    final isOverBudget = spent > target;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.currencySymbol}${spent.toStringAsFixed(0)} / ${provider.currencySymbol}${target.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 1 ? 1 : progress,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? Colors.red : color,
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOverBudget
                    ? 'Over budget by ${provider.currencySymbol}${(spent - target).toStringAsFixed(0)}'
                    : '${provider.currencySymbol}${(target - spent).toStringAsFixed(0)} remaining',
                style: TextStyle(
                  color: isOverBudget ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsCard(
    BuildContext context,
    BudgetProvider provider, {
    required String title,
    required double amount,
    required double baseTarget,
    required double extraIncome,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${provider.currencySymbol}.${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Includes 20% allocation (${provider.currencySymbol}${baseTarget.toStringAsFixed(0)}) + Extra Income (${provider.currencySymbol}${extraIncome.toStringAsFixed(0)})',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
