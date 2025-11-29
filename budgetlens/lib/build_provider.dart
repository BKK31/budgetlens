import 'package:flutter/foundation.dart';
import 'models.dart';
import 'calculator.dart';

class BudgetProvider extends ChangeNotifier{ // ChangeNotifier to allow state management
  final BudgetState state = BudgetState();
  final BudgetCalculator calculator = BudgetCalculator();

  void addExpense(double amount){
    calculator.addExpense(state, amount);
    notifyListeners(); // Notify listeners about state changes
  }

  void addIncome(double amount) {
    calculator.addIncome(state, amount);
    notifyListeners();
  }

  void switchMode() {
    calculator.switchMode(state);
    notifyListeners();
  }

  double get displayAmount {
    if(state.viewMode){
      return calculator.getRemainingToday(state);
    }else{
      return calculator.getRemainingBudget(state);
    }
  }

  int get daysRemaining {
    return calculator.getDaysRemaining(state);
  }

  double get dailyAllowance {
    return calculator.getDailyAllowance(state);
  }

  double get remainingBudget {
    return calculator.getRemainingBudget(state);
  }
}