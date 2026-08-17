import 'package:revtrack_mobile/core/utils/parsers.dart';

class ProjectModel {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final double amountPaid;
  final double remainingBudget;
  final String budgetStatus; // 'paid' ou 'unpaid'
  final String progressStatus; // 'ongoing', 'completed', 'delayed'
  final int progressPercentage;
  final bool isOverBudget;
  final int categoryId;
  final String? categoryName;
  final String? categoryColor;
  final int startupId;
  final int userId;
  final String? userName;
  final String? description;
  final List<ProjectTransaction>? transactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.budget,
    required this.amountPaid,
    required this.remainingBudget,
    required this.budgetStatus,
    required this.progressStatus,
    required this.progressPercentage,
    required this.isOverBudget,
    required this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.startupId,
    required this.userId,
    this.userName,
    this.description,
    this.transactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: Parsers.toInt(json['id']),
      name: json['name'] ?? '',
      startDate: Parsers.toDateTime(json['start_date']),
      endDate: json['end_date'] != null ? Parsers.toDateTime(json['end_date']) : null,
      budget: Parsers.toDouble(json['budget']),
      amountPaid: Parsers.toDouble(json['amount_paid']),
      remainingBudget: Parsers.toDouble(json['remaining_budget']),
      budgetStatus: json['budget_status'] ?? 'unpaid',
      progressStatus: json['progress_status'] ?? 'ongoing',
      progressPercentage: Parsers.toInt(json['progress_percentage']),
      isOverBudget: json['is_over_budget'] ?? false,
      categoryId: Parsers.toInt(json['category_id']),
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      startupId: Parsers.toInt(json['startup_id']),
      userId: Parsers.toInt(json['user_id']),
      userName: json['user_name'],
      description: json['description'],
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((t) => ProjectTransaction.fromJson(t))
              .toList()
          : null,
      createdAt: Parsers.toDateTime(json['created_at']),
      updatedAt: Parsers.toDateTime(json['updated_at']),
    );
  }
}

class ProjectTransaction {
  final int id;
  final double amount;
  final DateTime date;
  final String source;

  ProjectTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.source,
  });

  factory ProjectTransaction.fromJson(Map<String, dynamic> json) {
    return ProjectTransaction(
      id: Parsers.toInt(json['id']),
      amount: Parsers.toDouble(json['amount']),
      date: Parsers.toDateTime(json['date']),
      source: json['source'] ?? '',
    );
  }
}