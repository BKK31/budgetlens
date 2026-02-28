import 'models.dart';

class BudgetCalculator {
  double getRemainingBudget(BudgetState state) {
    double spendablePercentage = 0.8; // Default 50/30/20 spendable is 80%

    if (state.isCustomStrategy && state.categories.isNotEmpty) {
      // Calculate spendable percentage by summing non-savings categories
      double nonSavingsTotal = state.categories
          .where((cat) => !cat.isSavings)
          .fold(0.0, (sum, cat) => sum + cat.percentage);
      spendablePercentage = nonSavingsTotal / 100.0;
    }

    double spendableBudget = state.totalBudget * spendablePercentage;
    return spendableBudget - state.totalSpent;
  }

  int getDaysRemaining(BudgetState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      state.budgetEndDate.year,
      state.budgetEndDate.month,
      state.budgetEndDate.day,
    );

    int days = endDate.difference(today).inDays + 1;
    if (days <= 0) {
      return 1;
    }
    return days;
  }

  double getDailyAllowance(BudgetState state) {
    double daysRemaining = getDaysRemaining(state).toDouble();
    double remainingBudget = getRemainingBudget(state);
    return (remainingBudget + state.todaysSpend) / daysRemaining;
  }

  double getRemainingToday(BudgetState state) {
    return getDailyAllowance(state) - state.todaysSpend;
  }

  void addExpense(BudgetState state, double amount) {
    state.totalSpent += amount;
    state.todaysSpend += amount;
  }

  void addIncome(BudgetState state, double amount) {
    state.totalIncome += amount;
    // Income does not reduce spent in 50/30/20, it goes to savings.
    // However, if we want to track 'todaysSpend' purely as expense, we shouldn't reduce it either.
    // If todaysSpend tracks 'net', then we keep it. But for 50/30/20, we likely want 'todaysSpend' to be expenses only.
    // state.todaysSpend -= amount;
  }

  bool switchMode(BudgetState state) {
    state.viewMode = !state.viewMode;
    return state.viewMode;
  }
}
