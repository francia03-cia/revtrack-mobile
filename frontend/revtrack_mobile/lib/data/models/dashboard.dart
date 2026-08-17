import 'package:revtrack_mobile/core/utils/parsers.dart';

class DashboardKpis {
  final double today;
  final double thisWeek;
  final double thisMonth;
  final double thisYear;
  final double growth;
  final double monthlyGoal;
  final double goalProgress;

  DashboardKpis({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.growth,
    required this.monthlyGoal,
    required this.goalProgress,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    return DashboardKpis(
      today: Parsers.toDouble(json['today']),
      thisWeek: Parsers.toDouble(json['this_week']),
      thisMonth: Parsers.toDouble(json['this_month']),
      thisYear: Parsers.toDouble(json['this_year']),
      growth: Parsers.toDouble(json['growth']),
      monthlyGoal: Parsers.toDouble(json['monthly_goal']),
      goalProgress: Parsers.toDouble(json['goal_progress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'this_week': thisWeek,
      'this_month': thisMonth,
      'this_year': thisYear,
      'growth': growth,
      'monthly_goal': monthlyGoal,
      'goal_progress': goalProgress,
    };
  }
}

// ✅ AJOUTER CETTE CLASSE
class DashboardChartData {
  final List<RevenueByPeriod> revenueByPeriod;
  final List<RevenueByCategory> revenueByCategory;
  final List<TopSource> topSources;
  final double forecast;

  DashboardChartData({
    required this.revenueByPeriod,
    required this.revenueByCategory,
    required this.topSources,
    required this.forecast,
  });

  factory DashboardChartData.fromJson(Map<String, dynamic> json) {
    return DashboardChartData(
      revenueByPeriod: (json['revenue_by_period'] as List? ?? [])
          .map((item) => RevenueByPeriod.fromJson(item as Map<String, dynamic>))
          .toList(),
      revenueByCategory: (json['revenue_by_category'] as List? ?? [])
          .map((item) => RevenueByCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      topSources: (json['top_sources'] as List? ?? [])
          .map((item) => TopSource.fromJson(item as Map<String, dynamic>))
          .toList(),
      forecast: Parsers.toDouble(json['forecast']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue_by_period': revenueByPeriod.map((e) => e.toJson()).toList(),
      'revenue_by_category': revenueByCategory.map((e) => e.toJson()).toList(),
      'top_sources': topSources.map((e) => e.toJson()).toList(),
      'forecast': forecast,
    };
  }
}

class RevenueByPeriod {
  final String period;
  final double total;

  RevenueByPeriod({required this.period, required this.total});

  factory RevenueByPeriod.fromJson(Map<String, dynamic> json) {
    return RevenueByPeriod(
      period: json['period'] ?? '',
      total: Parsers.toDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'total': total,
    };
  }
}

class RevenueByCategory {
  final String categoryName;
  final String categoryColor;
  final double total;

  RevenueByCategory({
    required this.categoryName,
    required this.categoryColor,
    required this.total,
  });

  factory RevenueByCategory.fromJson(Map<String, dynamic> json) {
    return RevenueByCategory(
      categoryName: json['category_name'] ?? 'Inconnu',
      categoryColor: json['category_color'] ?? '#4F46E5',
      total: Parsers.toDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'category_color': categoryColor,
      'total': total,
    };
  }
}

class TopSource {
  final String source;
  final double total;

  TopSource({required this.source, required this.total});

  factory TopSource.fromJson(Map<String, dynamic> json) {
    return TopSource(
      source: json['source'] ?? '',
      total: Parsers.toDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'total': total,
    };
  }
}