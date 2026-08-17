import 'package:flutter/material.dart';
import 'package:revtrack_mobile/core/constants/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String) onLanguageChange;

  const SettingsScreen({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section Langue
          _buildSectionHeader(AppStrings.language),
          
          _buildLanguageTile(
            title: AppStrings.french,
            languageCode: 'fr',
            icon: Icons.translate,
            onTap: () => _changeLanguage('fr'),
          ),
          
          _buildLanguageTile(
            title: AppStrings.english,
            languageCode: 'en',
            icon: Icons.translate,
            onTap: () => _changeLanguage('en'),
          ),
          
          const Divider(height: 32),
          
          // Section Notifications
          _buildSectionHeader(AppStrings.notifications),
          _buildSwitchTile(
            title: AppStrings.dailyReminder,
            subtitle: AppStrings.reminderHour,
            value: true,
            onChanged: (value) {},
          ),
          _buildSwitchTile(
            title: AppStrings.alertOnGoal,
            value: true,
            onChanged: (value) {},
          ),
          _buildSwitchTile(
            title: AppStrings.alertOnDrop,
            value: false,
            onChanged: (value) {},
          ),
          _buildSwitchTile(
            title: AppStrings.weeklyReport,
            value: true,
            onChanged: (value) {},
          ),
          
          const Divider(height: 32),
          
          // Section Autres
          _buildSectionHeader(AppStrings.profile),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppStrings.profile),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppStrings.logout),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String title,
    required String languageCode,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: AppStrings.currentLanguage == languageCode
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
      onTap: () => onChanged(!value),
    );
  }

  void _changeLanguage(String langCode) {
    onLanguageChange(langCode);
    // Optionnel : Afficher un message de confirmation
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Langue changée avec succès !'),
    //     duration: const Duration(seconds: 2),
    //   ),
    // );
  }
}