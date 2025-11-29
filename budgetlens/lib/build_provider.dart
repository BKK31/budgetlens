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
}