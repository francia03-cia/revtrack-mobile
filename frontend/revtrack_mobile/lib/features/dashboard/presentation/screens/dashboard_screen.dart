import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../data/repositories/startup_repository.dart';
import '../../../../data/models/startup.dart';
import '../../../../data/models/dashboard.dart';
import '../../../../core/theme/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final StartupRepository _startupRepository = StartupRepository();
  
  String _selectedPeriod = 'month';
  bool _isLoading = true;
  DashboardKpis? _kpisData;
  DashboardChartData? _chartData;
  List<StartupModel> _startups = [];
  int? _selectedStartupId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _startups = await _startupRepository.getStartups();
      print('🏢 Startups chargées: ${_startups.length}');
      
      if (_startups.isNotEmpty && _selectedStartupId == null) {
        _selectedStartupId = _startups.first.id;
      }

      if (_selectedStartupId != null) {
        _kpisData = await _dashboardRepository.getKpis(
          startupId: _selectedStartupId,
        );
        print('📊 KPIs: ${_kpisData?.toJson()}');

        _chartData = await _dashboardRepository.getChartData(
          startupId: _selectedStartupId,
          period: _selectedPeriod,
        );
        print('📊 Charts: ${_chartData?.toJson()}');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Dashboard Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  String _getStartupName() {
    if (_startups.isEmpty) return 'Aucune startup';
    final startup = _startups.firstWhere(
      (s) => s.id == _selectedStartupId,
      orElse: () => _startups.first,
    );
    return startup.name;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement du tableau de bord...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    // ✅ AGRÉGER LES CATÉGORIES EN DOUBLE
    final Map<String, RevenueByCategory> aggregatedCategories = {};
    for (var item in (_chartData?.revenueByCategory ?? [])) {
      final key = item.categoryName;
      if (aggregatedCategories.containsKey(key)) {
        // Additionner les totaux
        final existing = aggregatedCategories[key]!;
        aggregatedCategories[key] = RevenueByCategory(
          categoryName: existing.categoryName,
          categoryColor: existing.categoryColor,
          total: existing.total + item.total,
        );
      } else {
        aggregatedCategories[key] = item;
      }
    }
    final List<RevenueByCategory> uniqueCategories = aggregatedCategories.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.insights, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.activeStartup,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(
                      _getStartupName(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    if (_startups.length > 1)
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.black),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.revenueOverview,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    '${AppStrings.lastUpdate}: ${DateTime.now().toLocal().toString().substring(0, 16)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // KPIs Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final int crossAxisCount = width > 700 ? 4 : 2;
                  final double childAspectRatio = width > 700 ? 1.3 : 1.5;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildKpiCard(
                        AppStrings.today,
                        _formatAmount(_kpisData?.today ?? 0),
                        _formatGrowth(_kpisData?.growth ?? 0),
                      ),
                      _buildKpiCard(
                        AppStrings.week,
                        _formatAmount(_kpisData?.thisWeek ?? 0),
                        _formatGrowth(_kpisData?.growth ?? 0),
                      ),
                      _buildKpiCard(
                        AppStrings.month,
                        _formatAmount(_kpisData?.thisMonth ?? 0),
                        _formatGrowth(_kpisData?.growth ?? 0),
                      ),
                      _buildKpiCard(
                        AppStrings.year,
                        _formatAmount(_kpisData?.thisYear ?? 0),
                        _formatGrowth(_kpisData?.growth ?? 0),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Goal Progress Card
              _buildGoalProgressCard(),
              const SizedBox(height: 16),

              // Revenue Evolution Card
              _buildRevenueEvolutionCard(),
              const SizedBox(height: 16),

              // Category Distribution Card (avec catégories uniques)
              _buildCategoryDistributionCard(uniqueCategories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String amount, String trend) {
    final isPositive = trend.startsWith('+');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              amount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPositive ? const Color(0xFF6CF8BB).withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 10,
                    color: isPositive ? const Color(0xFF006C49) : Colors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend,
                    style: TextStyle(
                      fontSize: 10,
                      color: isPositive ? const Color(0xFF006C49) : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard() {
    final monthlyGoal = _kpisData?.monthlyGoal ?? 0;
    final thisMonth = _kpisData?.thisMonth ?? 0;
    final progress = monthlyGoal > 0 ? (thisMonth / monthlyGoal) * 100 : 0;
    final remaining = monthlyGoal - thisMonth;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.goalProgress,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 110,
                  width: 110,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      '${AppStrings.of} ${_formatAmount(monthlyGoal)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                children: [
                  if (remaining > 0)
                    TextSpan(text: "${AppStrings.aheadOfTarget} "),
                  TextSpan(
                    text: _formatAmount(remaining > 0 ? remaining : 0),
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                  if (remaining > 0)
                    TextSpan(text: '. ${AppStrings.keepPushing}!'),
                  if (remaining <= 0)
                    const TextSpan(text: '🎉 Objectif atteint !'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueEvolutionCard() {
    final revenueData = _chartData?.revenueByPeriod ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.revenueEvolution,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Prévision: ${_formatAmount(_chartData?.forecast ?? 0)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildPeriodButton('Jour', 'day'),
                      _buildPeriodButton('Semaine', 'week'),
                      _buildPeriodButton('Mois', 'month'),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            if (revenueData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('Aucune donnée disponible'),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: CustomPaint(
                  painter: LineChartPainter(revenueData: revenueData),
                ),
              ),
            const SizedBox(height: 12),
            if (revenueData.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: revenueData.map((item) {
                  return Expanded(
                    child: Text(
                      item.period,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            // ✅ AFFICHER LA PRÉVISION
            if ((_chartData?.forecast ?? 0) > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.trending_up, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Prévision du jour suivant: ${_formatAmount(_chartData?.forecast ?? 0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final active = value == _selectedPeriod;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
          _loadData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionCard(List<RevenueByCategory> categories) {
    final total = categories.fold(0.0, (sum, item) => sum + item.total);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.revenueByCategory,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ${_formatAmount(total)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Aucune catégorie'),
                ),
              )
            else
              Column(
                children: categories.map((item) {
                  final color = Color(int.parse(
                    item.categoryColor.substring(1),
                    radix: 16,
                  ) + 0xFF000000);
                  final percent = total > 0 ? (item.total / total * 100) : 0;
                  return _buildLegendItem(
                    item.categoryName,
                    '${percent.toStringAsFixed(1)}%',
                    color,
                    item.total,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String percent, Color color, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatAmount(amount),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Text(
            percent,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == 0) return '0 Ar';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M Ar';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K Ar';
    }
    return '${value.toStringAsFixed(0)} Ar';
  }

  String _formatGrowth(double value) {
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
  }
}

// ✅ CUSTOM PAINTER CORRIGÉ POUR LE GRAPHIQUE
class LineChartPainter extends CustomPainter {
  final List<RevenueByPeriod> revenueData;

  LineChartPainter({required this.revenueData});

  @override
  void paint(Canvas canvas, Size size) {
    if (revenueData.isEmpty) return;

    // Trouver le maximum
    final maxValue = revenueData.fold<double>(
      0,
      (max, item) => item.total > max ? item.total : max,
    );

    if (maxValue == 0) {
      // Afficher un message si aucune donnée
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Aucune donnée',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
      );
      return;
    }

    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gradient de remplissage
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryColor.withOpacity(0.3),
          AppTheme.primaryColor.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final padding = EdgeInsets.all(16);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;
    final step = chartWidth / (revenueData.length - 1);

    for (int i = 0; i < revenueData.length; i++) {
      final x = padding.left + i * step;
      final normalizedValue = revenueData[i].total / maxValue;
      final y = padding.top + chartHeight - (normalizedValue * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = padding.left + (i - 1) * step;
        final prevNormalizedValue = revenueData[i - 1].total / maxValue;
        final prevY = padding.top + chartHeight - (prevNormalizedValue * chartHeight);
        path.quadraticBezierTo(
          (prevX + x) / 2,
          (prevY + y) / 2,
          x,
          y,
        );
      }
    }

    // Remplir sous la courbe
    final fillPath = Path.from(path);
    fillPath.lineTo(padding.left + (revenueData.length - 1) * step, size.height - padding.bottom);
    fillPath.lineTo(padding.left, size.height - padding.bottom);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Points sur la courbe
    final dotPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    final borderDotPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < revenueData.length; i++) {
      final x = padding.left + i * step;
      final normalizedValue = revenueData[i].total / maxValue;
      final y = padding.top + chartHeight - (normalizedValue * chartHeight);

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 4, borderDotPaint);
    }

    // Point actif (dernier point)
    if (revenueData.isNotEmpty) {
      final lastIndex = revenueData.length - 1;
      final lastX = padding.left + lastIndex * step;
      final lastNormalizedValue = revenueData[lastIndex].total / maxValue;
      final lastY = padding.top + chartHeight - (lastNormalizedValue * chartHeight);

      final activeDotPaint = Paint()
        ..color = AppTheme.primaryColor
        ..style = PaintingStyle.fill;
      final activeBorderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(lastX, lastY), 7, activeDotPaint);
      canvas.drawCircle(Offset(lastX, lastY), 7, activeBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}