import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';
import 'calculator.dart';
import 'currency_data.dart';

class BudgetProvider extends ChangeNotifier {
  List<Transaction> transactions = [];
  final BudgetState state = BudgetState();

  final BudgetCalculator calculator = BudgetCalculator();

  double _previewAmount = 0.0;
  bool _previewIsIncome = false;

  void checkAndResetForNewDay() {
    final today = DateTime.now().day;

    if (today != state.lastTransactionDay) {
      // New day - reset
      state.todaysSpend = 0.0;
      state.lastTransactionDay = today;
    } else {
      // Same day - recalculate from today's transactions (Expenses Only)
      final now = DateTime.now();
      state.todaysSpend = transactions
          .where(
            (t) =>
                t.datetime.day == now.day &&
                t.datetime.month == now.month &&
                t.datetime.year == now.year &&
                t.amount > 0, // Only expenses
          )
          .fold(0, (sum, t) => sum + t.amount);
    }
  }

  void addExpense(double amount) {
    calculator.addExpense(state, amount);
    notifyListeners();
  }

  void addIncome(double amount) {
    calculator.addIncome(state, amount);
    notifyListeners();
  }

  void updatePreview(double amount, bool isIncome) {
    _previewAmount = amount;
    _previewIsIncome = isIncome;
    notifyListeners();
  }

  void switchMode() {
    calculator.switchMode(state);
    notifyListeners();
  }

  double get displayAmount {
    checkAndResetForNewDay();
    if (state.viewMode) {
      return calculator.getRemainingToday(state);
    } else {
      return calculator.getRemainingBudget(state);
    }
  }

  double get projectedDisplayAmount {
    double currentAmount = displayAmount;
    if (_previewAmount == 0) return currentAmount;

    double change = _previewIsIncome ? _previewAmount : -_previewAmount;
    return currentAmount + change;
  }

  int get daysRemaining {
    return calculator.getDaysRemaining(state);
  }

  double get dailyAllowance {
    checkAndResetForNewDay();
    return state.dailyAllowance;
  }

  double get remainingBudget {
    return calculator.getRemainingBudget(state);
  }

  void recordTransaction(
    double amount,
    String tag, {
    CategoryType categoryType = CategoryType.needs,
  }) {
    checkAndResetForNewDay();
    Transaction newTransaction = Transaction(
      amount,
      tag,
      DateTime.now(),
      categoryType: categoryType,
    );
    transactions.add(newTransaction);
    if (amount < 0) {
      // Income
      state.totalIncome += amount.abs();
    } else {
      // Expense
      state.totalSpent += amount;
      state.todaysSpend += amount;
      if (categoryType == CategoryType.needs) {
        state.needsSpent += amount;
      } else if (categoryType == CategoryType.wants) {
        state.wantsSpent += amount;
      }
    }
    saveTransactions();
    notifyListeners();
  }

  List<String> get uniqueTags {
    return transactions.map((t) => t.tag).toSet().toList();
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('hasLaunchedBefore');
  }

  Future<void> markLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLaunchedBefore', true);
  }

  String get currencySymbol =>
      CurrencyData.currencySymbols[state.currencyCode] ?? state.currencyCode;

  Future<void> saveBudgetSetup(
    double budget,
    DateTime startDate,
    DateTime endDate, {
    String currencyCode = 'INR',
  }) async {
    state.totalBudget = budget;
    state.budgetStartDate = startDate;
    state.budgetEndDate = endDate;
    state.currencyCode = currencyCode;
    state.totalSpent = 0.0;
    state.totalIncome = 0.0;
    state.needsSpent = 0.0;
    state.wantsSpent = 0.0;
    state.todaysSpend = 0.0;
    state.lastTransactionDay = DateTime.now().day;
    transactions.clear();
    state.dailyAllowance = calculator.getDailyAllowance(state);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalBudget', budget);
    await prefs.setString('startDate', startDate.toString());
    await prefs.setString('endDate', endDate.toString());
    await prefs.setString('currencyCode', currencyCode);

    await markLaunchComplete();
    notifyListeners();
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionData = transactions.map((t) {
      return {
        'id': t.id,
        'amount': t.amount,
        'tag': t.tag,
        'datetime': t.datetime.toString(),
        'categoryType': t.categoryType.index, // Save index for simplicity
      };
    }).toList();

    await prefs.setString('transactions', jsonEncode(transactionData));
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionString = prefs.getString('transactions');

    if (transactionString != null) {
      final List<dynamic> decoded = jsonDecode(transactionString);
      transactions = decoded.map((t) {
        return Transaction(
          t['amount'] as double,
          t['tag'] as String,
          DateTime.parse(t['datetime'] as String),
          categoryType: t['categoryType'] != null
              ? CategoryType.values[t['categoryType'] as int]
              : CategoryType.needs, // Default for legacy
          id: t['id'] as String?,
        );
      }).toList();

      recalculateTotalSpent();
    }
    notifyListeners();
  }

  Future<void> loadSavedBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBudget = prefs.getDouble('totalBudget');
    final savedStartDate = prefs.getString('startDate');
    final savedEndDate = prefs.getString('endDate');
    final savedCurrency = prefs.getString('currencyCode');

    if (savedBudget != null && savedStartDate != null && savedEndDate != null) {
      state.totalBudget = savedBudget;
      state.budgetStartDate = DateTime.parse(savedStartDate);
      state.budgetEndDate = DateTime.parse(savedEndDate);
    }

    if (savedCurrency != null) {
      state.currencyCode = savedCurrency;
    }

    await loadTransactions();
    checkAndResetForNewDay();
    notifyListeners();
  }

  Future<void> debugCheckLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.containsKey('hasLaunchedBefore');
    print('DEBUG: hasLaunchedBefore = $hasLaunched');
    final budget = prefs.getDouble('totalBudget');
    print('DEBUG: totalBudget = $budget');
  }

  Future<void> updateBudgetSetup(
    double newBudget,
    DateTime newStartDate,
    DateTime newEndDate,
  ) async {
    state.totalBudget = newBudget;
    state.budgetStartDate = newStartDate;
    state.budgetEndDate = newEndDate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalBudget', newBudget);
    await prefs.setString('startDate', newStartDate.toString());
    await prefs.setString('endDate', newEndDate.toString());
    await prefs.setString('currencyCode', state.currencyCode);

    notifyListeners();
  }

  Future<void> setCurrency(String currencyCode) async {
    state.currencyCode = currencyCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCode', currencyCode);
    notifyListeners();
  }

  Future<String> createBackup() async {
    final Map<String, dynamic> backupData = {
      'totalBudget': state.totalBudget,
      'startDate': state.budgetStartDate.toString(),
      'endDate': state.budgetEndDate.toString(),
      'currencyCode': state.currencyCode,
      'transactions': transactions.map((t) {
        return {
          'id': t.id,
          'amount': t.amount,
          'tag': t.tag,
          'datetime': t.datetime.toString(),
          'categoryType': t.categoryType.index,
        };
      }).toList(),
    };
    return jsonEncode(backupData);
  }

  Future<void> restoreBackup(String jsonString) async {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      // Validate required fields
      if (!decoded.containsKey('totalBudget') ||
          !decoded.containsKey('startDate') ||
          !decoded.containsKey('endDate') ||
          !decoded.containsKey('transactions')) {
        throw Exception('Invalid backup file format');
      }

      final newBudget = decoded['totalBudget'] as double;
      final newStartDate = DateTime.parse(decoded['startDate'] as String);
      final newEndDate = DateTime.parse(decoded['endDate'] as String);
      final newCurrency = decoded['currencyCode'] as String? ?? 'INR';
      final List<dynamic> newTransactionsJson = decoded['transactions'];

      final newTransactions = newTransactionsJson.map((t) {
        return Transaction(
          t['amount'] as double,
          t['tag'] as String,
          DateTime.parse(t['datetime'] as String),
          categoryType: t['categoryType'] != null
              ? CategoryType.values[t['categoryType'] as int]
              : CategoryType.needs,
          id: t['id'] as String?,
        );
      }).toList();

      // Save everything
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('totalBudget', newBudget);
      await prefs.setString('startDate', newStartDate.toString());
      await prefs.setString('endDate', newEndDate.toString());
      await prefs.setString('currencyCode', newCurrency);

      // Save transactions directly
      final transactionData = newTransactions.map((t) {
        return {
          'id': t.id,
          'amount': t.amount,
          'tag': t.tag,
          'datetime': t.datetime.toString(),
          'categoryType': t.categoryType.index,
        };
      }).toList();
      await prefs.setString('transactions', jsonEncode(transactionData));

      // Mark launch complete just in case
      await markLaunchComplete();
    } catch (e) {
      print('Error restoring backup: $e');
      rethrow;
    }
  }

  // Check if Budget is expired
  bool get isBudgetExpired {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final end = DateTime(
      state.budgetEndDate.year,
      state.budgetEndDate.month,
      state.budgetEndDate.day,
    );

    return today.isAfter(end);
  }

  // Recalculate Total Spent
  void recalculateTotalSpent() {
    final validTransactions = transactions.where(
      (t) =>
          t.datetime.isAfter(state.budgetStartDate) ||
          t.datetime.isAtSameMomentAs(state.budgetStartDate),
    );

    state.totalSpent = validTransactions
        .where((t) => t.amount > 0)
        .fold(0, (sum, t) => sum + t.amount);

    state.totalIncome = validTransactions
        .where((t) => t.amount < 0)
        .fold(0, (sum, t) => sum + t.amount.abs());

    state.needsSpent = validTransactions
        .where((t) => t.amount > 0 && t.categoryType == CategoryType.needs)
        .fold(0, (sum, t) => sum + t.amount);

    state.wantsSpent = validTransactions
        .where((t) => t.amount > 0 && t.categoryType == CategoryType.wants)
        .fold(0, (sum, t) => sum + t.amount);

    notifyListeners();
  }

  // Extend Budget
  Future<void> extendBudget(DateTime newEndDate) async {
    await updateBudgetSetup(
      state.totalBudget,
      state.budgetStartDate,
      newEndDate,
    );
  }

  // Rollover the remaining amount from budget
  Future<void> rolloverBudget(
    double additionalAmount,
    DateTime newEndDate,
  ) async {
    // Calculate remaining amount
    double remaining = calculator.getRemainingBudget(state);

    // Calculate new total budget
    double newTotal = remaining + additionalAmount;

    // Set new start date
    DateTime newStart = DateTime.now();

    // Update budget
    await updateBudgetSetup(newTotal, newStart, newEndDate);

    // Recalculate spent amount
    recalculateTotalSpent();
  }

  // Delete Transaction
  void deleteTransaction(String id) {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      // Logic: Just remove and recalculate.
      // Re-calculating from scratch is safer than doing complex manual rollback logic
      // because we have different buckets (Needs/Wants/Savings/Income).
      transactions.removeAt(index);
      saveTransactions();
      recalculateTotalSpent();
      checkAndResetForNewDay(); // Ensure todaysSpend is correct
    }
  }

  // Update Transaction
  void updateTransaction(Transaction updatedTransaction) {
    final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      transactions[index] = updatedTransaction;
      saveTransactions();
      recalculateTotalSpent();
      checkAndResetForNewDay();
    }
  }
}
