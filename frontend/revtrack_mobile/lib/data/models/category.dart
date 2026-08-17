import 'package:revtrack_mobile/core/utils/parsers.dart';

class CategoryModel {
  final int id;
  final String name;
  final String color;
  final String icon;
  final int? parentId;
  final bool isDefault;
  final String fullPath;
  final int totalTransactions;
  final double totalAmount;
  final List<CategoryModel>? children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.parentId,
    this.isDefault = false,
    this.fullPath = '',
    this.totalTransactions = 0,
    this.totalAmount = 0,
    this.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: Parsers.toInt(json['id']),
      name: json['name'] ?? '',
      color: json['color'] ?? '#4F46E5',
      icon: json['icon'] ?? 'category',
      parentId: json['parent_id'],
      isDefault: json['is_default'] ?? false,
      fullPath: json['full_path'] ?? json['name'] ?? '',
      totalTransactions: Parsers.toInt(json['total_transactions']),
      totalAmount: Parsers.toDouble(json['total_amount']),
      children: json['children'] != null
          ? (json['children'] as List)
              .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'parent_id': parentId,
      'is_default': isDefault,
      'full_path': fullPath,
    };
  }
}