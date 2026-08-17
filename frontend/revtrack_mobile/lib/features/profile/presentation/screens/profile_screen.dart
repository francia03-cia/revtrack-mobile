import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revtrack_mobile/data/models/user.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NotificationRepository _notificationRepository = NotificationRepository();
  
  bool _dailySummary = true;
  bool _goalAchievements = true;
  bool _revenueDrops = false;
  bool _isLoading = false;
  Map<String, dynamic>? _notificationConfig;

  @override
  void initState() {
    super.initState();
    _loadNotificationConfig();
  }

  Future<void> _loadNotificationConfig() async {
    try {
      final config = await _notificationRepository.getConfig();
      setState(() {
        _notificationConfig = config;
        _dailySummary = config['daily_reminder'] ?? true;
        _goalAchievements = config['alert_on_goal'] ?? true;
        _revenueDrops = config['alert_on_drop'] ?? false;
      });
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> _updateNotificationConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationRepository.updateConfig(
        dailyReminder: _dailySummary,
        alertOnGoal: _goalAchievements,
        alertOnDrop: _revenueDrops,
        weeklyReport: true,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Préférences de notifications sauvegardées'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(AuthLogout());
  }

  void _changeLanguage(String langCode) {
    setState(() {
      AppStrings.changeLanguage(langCode);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          langCode == 'fr' 
              ? 'Langue changée en Français 🇫🇷' 
              : 'Language changed to English 🇬🇧',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserModel?>(
      (bloc) => bloc.state is AuthAuthenticated
          ? (bloc.state as AuthAuthenticated).user
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Bouton de langue dans l'AppBar
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
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.black87),
            onPressed: _isLoading ? null : _updateNotificationConfig,
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Meta Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Utilisateur',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  user?.email ?? 'email@exemple.com',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    AppStrings.proPlan,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section Langue
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                child: Text(
                  AppStrings.language,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    _buildLanguageTile(
                      title: AppStrings.french,
                      languageCode: 'fr',
                      flag: '🇫🇷',
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildLanguageTile(
                      title: AppStrings.english,
                      languageCode: 'en',
                      flag: '🇬🇧',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notifications Group Title
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.notifications,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              // Notification Switches Card
              Card(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      AppStrings.dailyRevenueSummary,
                      AppStrings.dailyRevenueSummaryDesc,
                      Icons.calendar_today,
                      Colors.indigo,
                      _dailySummary,
                      (val) => setState(() => _dailySummary = val),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      AppStrings.goalAchievements,
                      AppStrings.goalAchievementsDesc,
                      Icons.stars,
                      Colors.orange,
                      _goalAchievements,
                      (val) => setState(() => _goalAchievements = val),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      AppStrings.revenueDrops,
                      AppStrings.revenueDropsDesc,
                      Icons.warning,
                      Colors.red,
                      _revenueDrops,
                      (val) => setState(() => _revenueDrops = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Security & App List Settings Title
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                child: Text(
                  AppStrings.securityAndApp,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Security Options list card
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.fingerprint, color: Colors.black54),
                      title: Text(
                        AppStrings.biometricAuthentication,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined, color: Colors.black54),
                      title: Text(
                        AppStrings.themeSelection,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        AppStrings.lightTheme,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        AppStrings.signOut,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Center(
                child: Text(
                  AppStrings.appVersion,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String title,
    required String languageCode,
    required String flag,
  }) {
    final isSelected = AppStrings.currentLanguage == languageCode;
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () {
        _changeLanguage(languageCode);
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    String desc,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChange,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Text(
        desc,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChange,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}