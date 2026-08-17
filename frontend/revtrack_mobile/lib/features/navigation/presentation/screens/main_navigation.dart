import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../../core/theme/colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const ProjectsScreen(),   // ✅ Projets après Transactions
    const ReportsScreen(),
    const CategoriesScreen(), // ✅ Catégories
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.black87),
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'fr',
                child: Row(
                  children: [
                    const Text('🇫🇷'),
                    const SizedBox(width: 8),
                    Text(AppStrings.french),
                    if (AppStrings.currentLanguage == 'fr') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.green, size: 18),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text('🇬🇧'),
                    const SizedBox(width: 8),
                    Text(AppStrings.english),
                    if (AppStrings.currentLanguage == 'en') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.green, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isTablet
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) {
                    setState(() => _currentIndex = idx);
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryColor),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: Text(AppStrings.home),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.list_alt_outlined),
                      selectedIcon: const Icon(Icons.list_alt),
                      label: Text(AppStrings.transactions),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.folder_outlined),
                      selectedIcon: const Icon(Icons.folder),
                      label: const Text('Projets'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.analytics_outlined),
                      selectedIcon: const Icon(Icons.analytics),
                      label: Text(AppStrings.reports),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.category_outlined),
                      selectedIcon: const Icon(Icons.category),
                      label: const Text('Catégories'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: const Icon(Icons.person),
                      label: Text(AppStrings.profile),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            )
          : _screens[_currentIndex],
      bottomNavigationBar: isTablet
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              onTap: (idx) {
                setState(() => _currentIndex = idx);
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: AppStrings.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.list_alt_outlined),
                  activeIcon: const Icon(Icons.list_alt),
                  label: AppStrings.transactions,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.folder_outlined),
                  activeIcon: const Icon(Icons.folder),
                  label: 'Projets',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.analytics_outlined),
                  activeIcon: const Icon(Icons.analytics),
                  label: AppStrings.reports,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.category_outlined),
                  activeIcon: const Icon(Icons.category),
                  label: 'Catégories',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: AppStrings.profile,
                ),
              ],
            ),
    );
  }

  void _changeLanguage(String langCode) {
    setState(() {
      AppStrings.changeLanguage(langCode);
    });
  }
}