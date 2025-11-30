import 'models.dart';

class BudgetCalculator {
  double getRemainingBudget(BudgetState state) {
    return state.totalBudget - state.totalSpent;
  }

  int getDaysRemaining(BudgetState state) {
  int days = state.budgetEndDate.difference(DateTime.now()).inDays + 2;
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
    double dailyAllowance = getDailyAllowance(state);
    return dailyAllowance - state.todaysSpend;
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
