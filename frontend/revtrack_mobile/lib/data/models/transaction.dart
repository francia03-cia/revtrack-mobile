import 'package:revtrack_mobile/core/utils/parsers.dart';
class TransactionModel {
  final int id;
  final double amount;
  final String formattedAmount;
  final DateTime date;
  final String source;
  final String? note;
  final String? receipt;
  final List<String>? tags;
  final int startupId;
  final String? startupName;
  final int categoryId;
  final String? categoryName;
  final String? categoryColor;
  final int userId;
  final String? userName;
  final bool isRecurring;
  final String? recurringFrequency;
  final bool isHighValue;
  final bool isLowValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? projectId;
  final String? projectName;

  TransactionModel({
    required this.id,
    required this.amount,
    this.formattedAmount = '',
    required this.date,
    required this.source,
    this.note,
    this.receipt,
    this.tags,
    required this.startupId,
    this.startupName,
    required this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.userId,
    this.userName,
    this.isRecurring = false,
    this.recurringFrequency,
    this.isHighValue = false,
    this.isLowValue = false,
    required this.createdAt,
    required this.updatedAt,
    this.projectId,
    this.projectName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: Parsers.toInt(json['id']),
      amount: Parsers.toDouble(json['amount']),
      formattedAmount: json['formatted_amount'] ?? '',
      date: Parsers.toDateTime(json['date']),
      source: json['source'] ?? '',
      note: json['note'],
      receipt: json['receipt'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      startupId: Parsers.toInt(json['startup_id']),
      startupName: json['startup_name'],
      categoryId: Parsers.toInt(json['category_id']),
      categoryName: json['category_name'] ?? json['category']?['name'],
      categoryColor: json['category_color'] ?? json['category']?['color'],
      userId: Parsers.toInt(json['user_id']),
      userName: json['user_name'],
      isRecurring: json['is_recurring'] ?? false,
      recurringFrequency: json['recurring_frequency'],
      isHighValue: json['is_high_value'] ?? false,
      isLowValue: json['is_low_value'] ?? false,
      createdAt: Parsers.toDateTime(json['created_at']),
      updatedAt: Parsers.toDateTime(json['updated_at']),
      projectId: json['project_id'],
      projectName: json['project_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'source': source,
      'note': note,
      'receipt': receipt,
      'tags': tags,
      'startup_id': startupId,
      'category_id': categoryId,
    };
  }
}