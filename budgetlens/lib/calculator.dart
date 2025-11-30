import 'models.dart';

class BudgetCalculator {
  double getRemainingBudget(BudgetState state) {
    return state.totalBudget - state.totalSpent;
  }

  int getDaysRemaining(BudgetState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate =
        DateTime(state.budgetEndDate.year, state.budgetEndDate.month, state.budgetEndDate.day);

    int days = endDate.difference(today).inDays + 1;
    if (days <= 0) {
      return 1;
    }
    return days;
  }

  double getDailyAllowance(BudgetState state) {
    double daysRemaining = getDaysRemaining(state).toDouble();
    double remainingBudget = getRemainingBudget(state);
    return remainingBudget / daysRemaining;
  }

  double getRemainingToday(BudgetState state) {
    return state.dailyAllowance - state.todaysSpend;
  }

  void addExpense(BudgetState state, double amount) {
    state.totalSpent += amount;
    state.todaysSpend += amount;
  }

  void addIncome(BudgetState state, double amount) {
    state.totalSpent -= amount;
    state.todaysSpend -= amount;
  }

  bool switchMode(BudgetState state) {
    state.viewMode = !state.viewMode;
    return state.viewMode;
  }
}
