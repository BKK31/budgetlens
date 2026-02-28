import 'package:uuid/uuid.dart';

class CustomCategory {
  String id;
  String name;
  double percentage;
  bool isSavings;

  CustomCategory({
    required this.id,
    required this.name,
    required this.percentage,
    this.isSavings = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'percentage': percentage,
    'isSavings': isSavings,
  };

  factory CustomCategory.fromJson(Map<String, dynamic> json) => CustomCategory(
    id: json['id'],
    name: json['name'],
    percentage: json['percentage'],
    isSavings: json['isSavings'] ?? false,
  );
}

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
  String currencyCode = 'INR';

  // Custom Categories strategy state
  bool isCustomStrategy = false;
  List<CustomCategory> categories = [];
  Map<String, double> categorySpent = {}; // Track spent per category id

  // Legacy fields (kept for migration/backward compatibility if needed)
  double needsSpent = 0.0;
  double wantsSpent = 0.0;
}

enum CategoryType { needs, wants, savings }

class Transaction {
  String id;
  double amount;
  String tag;
  DateTime datetime;

  // Legacy enum
  CategoryType categoryType;

  // New string ref to CustomCategory.id
  String? categoryId;

  Transaction(
    this.amount,
    this.tag,
    this.datetime, {
    this.categoryType = CategoryType.needs,
    this.categoryId,
    String? id,
  }) : id = id ?? const Uuid().v4();
}
