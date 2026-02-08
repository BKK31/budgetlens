import 'package:uuid/uuid.dart';

class BudgetState {
  double totalBudget = 0.0;
  double totalSpent = 0.0;
  bool viewMode = true;
  DateTime budgetStartDate = DateTime.now();
  DateTime budgetEndDate = DateTime.now();
  double todaysSpend = 0.0;
  int lastTransactionDay = DateTime.now().day;
  double dailyAllowance = 0.0;
  double totalIncome = 0.0;
  double needsSpent = 0.0;
  double wantsSpent = 0.0;
  String currencyCode = 'INR';
}

enum CategoryType { needs, wants, savings }

class Transaction {
  String id;
  double amount;
  String tag;
  DateTime datetime;
  CategoryType categoryType;

  Transaction(
    this.amount,
    this.tag,
    this.datetime, {
    this.categoryType = CategoryType.needs,
    String? id,
  }) : id = id ?? const Uuid().v4();
}
