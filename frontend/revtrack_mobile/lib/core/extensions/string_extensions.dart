import 'package:revtrack_mobile/core/constants/app_strings.dart';

extension StringExtensions on String {
  // Utilisation : context.l10n.welcome
  String get tr => AppStrings.translate({
    'fr': this,
    // Ajoutez les autres langues ici
  });
}