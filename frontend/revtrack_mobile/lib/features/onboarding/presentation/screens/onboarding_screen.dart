import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(String) onLanguageChange;

  const OnboardingScreen({super.key, required this.onLanguageChange});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'onboardingTitle1',
      description: 'onboardingDesc1',
      percentage: '+12%',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAL2niRW_3hdh7K20n0CFe4ZoX2MOLCHww_DyRYmTUEwvckvmVedVfjT340bM2-QX6ukN6_Y53TUNFG8BskJNKwvhCSHeylkm1PUOZ3iXl7E5ablx4fhC9UR8phT-vBUzVGj0er_T6dtlOvkK_HCIBkUdTAJQ9beguWJRLHX30tf-LtStFmW0o2JmCtj7dCN0hVSrkaQirKfSoTCwrRnyuZg5rYb3NWnFzb2OQxrfMSnBqdULxvVa3iqtFo6T0Gjjv1pHdP88R0TuBE',
    ),
    OnboardingSlide(
      title: 'onboardingTitle2',
      description: 'onboardingDesc2',
      percentage: 'Donut & Line',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAL2niRW_3hdh7K20n0CFe4ZoX2MOLCHww_DyRYmTUEwvckvmVedVfjT340bM2-QX6ukN6_Y53TUNFG8BskJNKwvhCSHeylkm1PUOZ3iXl7E5ablx4fhC9UR8phT-vBUzVGj0er_T6dtlOvkK_HCIBkUdTAJQ9beguWJRLHX30tf-LtStFmW0o2JmCtj7dCN0hVSrkaQirKfSoTCwrRnyuZg5rYb3NWnFzb2OQxrfMSnBqdULxvVa3iqtFo6T0Gjjv1pHdP88R0TuBE',
    ),
    OnboardingSlide(
      title: 'onboardingTitle3',
      description: 'onboardingDesc3',
      percentage: 'PDF & XLS',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAL2niRW_3hdh7K20n0CFe4ZoX2MOLCHww_DyRYmTUEwvckvmVedVfjT340bM2-QX6ukN6_Y53TUNFG8BskJNKwvhCSHeylkm1PUOZ3iXl7E5ablx4fhC9UR8phT-vBUzVGj0er_T6dtlOvkK_HCIBkUdTAJQ9beguWJRLHX30tf-LtStFmW0o2JmCtj7dCN0hVSrkaQirKfSoTCwrRnyuZg5rYb3NWnFzb2OQxrfMSnBqdULxvVa3iqtFo6T0Gjjv1pHdP88R0TuBE',
    ),
  ];

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _changeLanguage(String langCode) {
    // Appeler la fonction parent pour changer la langue
    widget.onLanguageChange(langCode);
    
    // Forcer le rebuild de l'écran
    setState(() {});
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          langCode == 'fr' 
              ? '🇫🇷 Langue changée en Français' 
              : '🇬🇧 Language changed to English',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          // Bouton de changement de langue dans l'AppBar
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 16),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: isTablet ? 300 : 260,
                                      width: isTablet ? 300 : 260,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(
                                          slide.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.analytics,
                                                size: 100,
                                                color: AppTheme.primaryColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6CF8BB),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.trending_up, size: 16, color: Color(0xFF005236)),
                                            const SizedBox(width: 4),
                                            Text(
                                              slide.percentage,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF005236),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  _getTitle(slide.title),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    _getDescription(slide.description),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: const Color(0xFF464555),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Pagination dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentIndex == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? AppTheme.primaryColor : const Color(0xFFC7C4D8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _navigateToLogin();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _slides.length - 1 ? AppStrings.getStarted : AppStrings.next,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        AppStrings.skipIntro,
                        style: const TextStyle(
                          color: Color(0xFF464555),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Affichage de la langue actuelle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppStrings.currentLanguage == 'fr' ? '🇫🇷 ${AppStrings.french}' : '🇬🇧 ${AppStrings.english}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle(String key) {
    switch (key) {
      case 'onboardingTitle1':
        return AppStrings.onboardingTitle1;
      case 'onboardingTitle2':
        return AppStrings.onboardingTitle2;
      case 'onboardingTitle3':
        return AppStrings.onboardingTitle3;
      default:
        return '';
    }
  }

  String _getDescription(String key) {
    switch (key) {
      case 'onboardingDesc1':
        return AppStrings.onboardingDesc1;
      case 'onboardingDesc2':
        return AppStrings.onboardingDesc2;
      case 'onboardingDesc3':
        return AppStrings.onboardingDesc3;
      default:
        return '';
    }
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String percentage;
  final String imageUrl;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.percentage,
    required this.imageUrl,
  });
}