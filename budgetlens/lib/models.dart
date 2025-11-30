class BudgetState{
  double totalBudget = 0.0;
  double totalSpent = 0.0;
  bool viewMode = true;
  DateTime budgetStartDate = DateTime.now();
  DateTime budgetEndDate = DateTime.now();
  double todaysSpend = 0.0;
  int lastTransactionDay = DateTime.now().day;
}

class Transaction{
  double amount;
  String tag;
  DateTime datetime;
  Transaction(this.amount, this.tag, this.datetime);
}