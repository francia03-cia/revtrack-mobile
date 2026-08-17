import 'package:revtrack_mobile/data/models/category.dart';

class StartupModel {
  final int id;
  final String name;
  final String? logo;
  final String currency;
  final String? email;
  final String? phone;
  final String? address;
  final int ownerId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StartupStats? stats;
  final List<CategoryModel>? categories;

  StartupModel({
    required this.id,
    required this.name,
    this.logo,
    required this.currency,
    this.email,
    this.phone,
    this.address,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
    this.categories,
  });

  factory StartupModel.fromJson(Map<String, dynamic> json) {
    return StartupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      currency: json['currency'] ?? 'Ar',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      ownerId: json['owner_id'] ?? 0,
      ownerName: json['owner_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      stats: json['stats'] != null
          ? StartupStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((cat) => CategoryModel.fromJson(cat as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'currency': currency,
      'email': email,
      'phone': phone,
      'address': address,
      'owner_id': ownerId,
      'owner_name': ownerName,
    };
  }
}

class StartupStats {
  final double totalRevenue;
  final double monthlyRevenue;
  final double dailyRevenue;
  final int transactionCount;
  final int categoryCount;
  final int userCount;

  StartupStats({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.dailyRevenue,
    required this.transactionCount,
    required this.categoryCount,
    required this.userCount,
  });

  factory StartupStats.fromJson(Map<String, dynamic> json) {
    return StartupStats(
      totalRevenue: _parseDouble(json['total_revenue']),
      monthlyRevenue: _parseDouble(json['monthly_revenue']),
      dailyRevenue: _parseDouble(json['daily_revenue']),
      transactionCount: _parseInt(json['transaction_count']),
      categoryCount: _parseInt(json['category_count']),
      userCount: _parseInt(json['user_count']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }
}