class AppStrings {
  // Langue actuelle (changeable dynamiquement)
  static String currentLanguage = 'fr'; // 'fr' ou 'en'
  
  // Méthode pour changer la langue
  static void changeLanguage(String langCode) {
    currentLanguage = langCode;
  }
  
  // Méthode utilitaire pour obtenir la traduction
  static String translate(Map<String, String> translations) {
    return translations[currentLanguage] ?? translations['fr'] ?? '';
  }
  
  // ============ ONBOARDING ============
  static String get onboardingTitle1 => translate({
    'fr': 'Suivi en temps réel des revenus',
    'en': 'Real-time Revenue Tracking',
  });
  
  static String get onboardingDesc1 => translate({
    'fr': 'Visualisez vos flux de trésorerie instantanément. Gardez le contrôle total sur votre croissance financière.',
    'en': 'Visualize your cash flow instantly. Keep full control over your financial growth.',
  });
  
  static String get onboardingTitle2 => translate({
    'fr': 'Analyse par graphiques interactifs',
    'en': 'Interactive Chart Analysis',
  });
  
  static String get onboardingDesc2 => translate({
    'fr': "Visualisez la répartition de vos revenus et comparez vos performances mensuelles d'un coup d'œil.",
    'en': 'Visualize your revenue distribution and compare monthly performance at a glance.',
  });
  
  static String get onboardingTitle3 => translate({
    'fr': 'Exportation de rapports PDF/Excel',
    'en': 'PDF/Excel Report Export',
  });
  
  static String get onboardingDesc3 => translate({
    'fr': 'Générez des rapports financiers professionnels pour vos investisseurs ou votre équipe en deux clics.',
    'en': 'Generate professional financial reports for your investors or team in two clicks.',
  });
  
  static String get appTitle => translate({
    'fr': 'NTECH-MONEY-MONITRING',
    'en': 'NTECH-MONEY-MONITRING',
  });
  
  static String get next => translate({
    'fr': 'Suivant',
    'en': 'Next',
  });
  
  static String get getStarted => translate({
    'fr': 'Commencer',
    'en': 'Get Started',
  });
  
  static String get skipIntro => translate({
    'fr': "Passer l'introduction",
    'en': 'Skip Introduction',
  });
  
  // ============ AUTHENTIFICATION ============
  static String get login => translate({
    'fr': 'Se connecter',
    'en': 'Login',
  });
  
  static String get register => translate({
    'fr': "S'inscrire",
    'en': 'Register',
  });
  
  static String get email => translate({
    'fr': 'Email',
    'en': 'Email',
  });
  
  static String get password => translate({
    'fr': 'Mot de passe',
    'en': 'Password',
  });
  
  static String get confirmPassword => translate({
    'fr': 'Confirmer le mot de passe',
    'en': 'Confirm Password',
  });
  
  static String get forgotPassword => translate({
    'fr': 'Mot de passe oublié ?',
    'en': 'Forgot Password?',
  });
  
  static String get welcome => translate({
    'fr': 'Bienvenue sur NTECH-MONEY-MONITRING',
    'en': 'Welcome to NTECH-MONEY-MONITRING',
  });
  
  static String get welcomeDescription => translate({
    'fr': 'Suivez vos revenus facilement et efficacement',
    'en': 'Track your revenue easily and efficiently',
  });
  
  static String get loginSubtitle => translate({
    'fr': 'Pilotez votre croissance financière',
    'en': 'Drive your financial growth',
  });
  
  static String get emailHint => translate({
    'fr': 'nom@entreprise.com',
    'en': 'name@company.com',
  });
  
  static String get passwordHint => translate({
    'fr': '••••••••',
    'en': '••••••••',
  });
  
  static String get emailRequired => translate({
    'fr': 'Entrez un email',
    'en': 'Enter an email',
  });
  
  static String get emailInvalid => translate({
    'fr': "Format d'email invalide",
    'en': 'Invalid email format',
  });
  
  static String get passwordMinLength => translate({
    'fr': 'Minimum 6 caractères',
    'en': 'Minimum 6 characters',
  });
  
  static String get orDivider => translate({
    'fr': 'OU',
    'en': 'OR',
  });
  
  static String get loginWithGoogle => translate({
    'fr': 'Connexion avec Google',
    'en': 'Login with Google',
  });
  
  static String get quickLogin => translate({
    'fr': 'CONNEXION RAPIDE',
    'en': 'QUICK LOGIN',
  });
  
  static String get useBiometrics => translate({
    'fr': 'Utiliser FaceID / TouchID',
    'en': 'Use FaceID / TouchID',
  });
  
  static String get biometricAuthTitle => translate({
    'fr': 'Authentification Biométrique',
    'en': 'Biometric Authentication',
  });
  
  static String get biometricAuthDescription => translate({
    'fr': "Posez votre doigt sur le capteur d'empreintes ou utilisez FaceID.",
    'en': 'Place your finger on the fingerprint sensor or use FaceID.',
  });
  
  static String get simulateSuccess => translate({
    'fr': 'Simuler succès',
    'en': 'Simulate success',
  });
  
  static String get newHere => translate({
    'fr': 'Nouveau ici ? ',
    'en': 'New here? ',
  });
  
  static String get createAccount => translate({
    'fr': 'Créer un compte',
    'en': 'Create an account',
  });
  
  static String get french => translate({
    'fr': 'Français',
    'en': 'French',
  });
  
  static String get english => translate({
    'fr': 'Anglais',
    'en': 'English',
  });
  
  // ============ NAVIGATION ============
  static String get home => translate({
    'fr': 'Accueil',
    'en': 'Home',
  });

  static String get source => translate({
    'fr': 'Source',
    'en': 'Source',
  });
  
  static String get transactions => translate({
    'fr': 'Transactions',
    'en': 'Transactions',
  });
  
  static String get reports => translate({
    'fr': 'Rapports',
    'en': 'Reports',
  });
  
  static String get more => translate({
    'fr': 'Plus',
    'en': 'More',
  });
  
  // ============ DASHBOARD ============
  static String get activeStartup => translate({
    'fr': 'Startup active',
    'en': 'Active Startup',
  });
  
  static String get revenueOverview => translate({
    'fr': 'APERÇU DES REVENUS',
    'en': 'REVENUE OVERVIEW',
  });
  
  static String get lastUpdate => translate({
    'fr': "Dernière mise à jour: À l'instant",
    'en': 'Last Update: Just now',
  });
  
  static String get today => translate({
    'fr': 'Aujourd\'hui',
    'en': 'Today',
  });
  
  static String get week => translate({
    'fr': 'Semaine',
    'en': 'Week',
  });
  
  static String get month => translate({
    'fr': 'Mois',
    'en': 'Month',
  });
  
  static String get year => translate({
    'fr': 'Année',
    'en': 'Year',
  });
  
  static String get day => translate({
    'fr': 'Jour',
    'en': 'Day',
  });
  
  static String get monthPeriod => translate({
    'fr': 'Mois',
    'en': 'Month',
  });
  
  static String get goalProgress => translate({
    'fr': 'Progression des objectifs',
    'en': 'Goal Progress',
  });
  
  static String get of => translate({
    'fr': 'sur',
    'en': 'of',
  });
  
  static String get aheadOfTarget => translate({
    'fr': "Vous êtes en avance sur l'objectif de",
    'en': "You're ahead of target by",
  });
  
  static String get keepPushing => translate({
    'fr': 'Continuez comme ça',
    'en': 'Keep pushing',
  });
  
  static String get revenueEvolution => translate({
    'fr': 'Évolution des revenus',
    'en': 'Revenue Evolution',
  });
  
  static String get revenueEvolutionSubtitle => translate({
    'fr': 'Tendances des revenus bruts dans le temps',
    'en': 'Gross revenue trends over time',
  });
  
  static String get revenueByCategory => translate({
    'fr': 'Revenus par catégorie',
    'en': 'Revenue by Category',
  });
  
  static String get total => translate({
    'fr': 'Total',
    'en': 'Total',
  });
  
  // Jours de la semaine
  static String get mon => translate({
    'fr': 'Lun',
    'en': 'Mon',
  });
  
  static String get tue => translate({
    'fr': 'Mar',
    'en': 'Tue',
  });
  
  static String get wed => translate({
    'fr': 'Mer',
    'en': 'Wed',
  });
  
  static String get thu => translate({
    'fr': 'Jeu',
    'en': 'Thu',
  });
  
  static String get fri => translate({
    'fr': 'Ven',
    'en': 'Fri',
  });
  
  static String get sat => translate({
    'fr': 'Sam',
    'en': 'Sat',
  });
  
  static String get sun => translate({
    'fr': 'Dim',
    'en': 'Sun',
  });
  
  // ============ PROFILE ============
  static String get profile => translate({
    'fr': 'Profil',
    'en': 'Profile',
  });
  
  static String get proPlan => translate({
    'fr': 'PLAN PRO',
    'en': 'PRO PLAN',
  });
  
  static String get revenueTarget => translate({
    'fr': 'OBJECTIF DE REVENU',
    'en': 'REVENUE TARGET',
  });
  
  static String get vsLY => translate({
    'fr': 'vs AN',
    'en': 'vs LY',
  });
  
  static String get upcomingGoal => translate({
    'fr': 'OBJECTIF À VENIR',
    'en': 'UPCOMING GOAL',
  });
  
  static String get q4_2024 => translate({
    'fr': 'T4 2024',
    'en': 'Q4 2024',
  });
  
  static String get dailyRevenueSummary => translate({
    'fr': 'Résumé quotidien des revenus',
    'en': 'Daily Revenue Summary',
  });
  
  static String get dailyRevenueSummaryDesc => translate({
    'fr': 'Tous les jours à 8h00',
    'en': 'Every day at 8:00 AM',
  });
  
  static String get goalAchievements => translate({
    'fr': 'Objectifs atteints',
    'en': 'Goal Achievements',
  });
  
  static String get goalAchievementsDesc => translate({
    'fr': 'Alerte lorsqu\'un objectif est atteint',
    'en': 'Alert when a target is met',
  });
  
  static String get revenueDrops => translate({
    'fr': 'Baisses de revenus',
    'en': 'Revenue Drops',
  });
  
  static String get revenueDropsDesc => translate({
    'fr': 'Détecter les volatilités inhabituelles',
    'en': 'Detect unusual volatility',
  });
  
  static String get securityAndApp => translate({
    'fr': 'Sécurité & Application',
    'en': 'Security & App',
  });
  
  static String get biometricAuthentication => translate({
    'fr': 'Authentification biométrique',
    'en': 'Biometric Authentication',
  });
  
  static String get themeSelection => translate({
    'fr': 'Sélection du thème',
    'en': 'Theme Selection',
  });
  
  static String get lightTheme => translate({
    'fr': 'Clair',
    'en': 'Light',
  });
  
  static String get signOut => translate({
    'fr': 'Se déconnecter',
    'en': 'Sign Out',
  });
  
  static String get appVersion => translate({
    'fr': 'Version 2.4.12-rev',
    'en': 'Version 2.4.12-rev',
  });
  
  // ============ REPORTS ============
  static String get reportsAndExports => translate({
    'fr': 'Rapports & Exportations',
    'en': 'Reports & Exports',
  });
  
  static String get monthlyFinancialSummary => translate({
    'fr': 'Résumé financier mensuel',
    'en': 'Monthly Financial Summary',
  });
  
  static String get lastUpdated => translate({
    'fr': 'Dernière mise à jour',
    'en': 'Last updated',
  });
  
  static String get exportingTo => translate({
    'fr': 'Exportation vers',
    'en': 'Exporting to',
  });
  
  static String get generatingFile => translate({
    'fr': 'Génération de votre fichier',
    'en': 'Generating your file',
  });
  
  static String get reportDownloaded => translate({
    'fr': 'Rapport',
    'en': 'Report',
  });
  
  static String get readyToShare => translate({
    'fr': 'téléchargé et prêt à être partagé !',
    'en': 'downloaded and ready to share!',
  });
  
  static String get share => translate({
    'fr': 'Partager',
    'en': 'Share',
  });
  
  static String get autoGenerateInsights => translate({
    'fr': 'Générer automatiquement des insights hebdomadaires',
    'en': 'Auto-generate weekly insights',
  });
  
  static String get exportPDF => translate({
    'fr': 'Exporter en PDF',
    'en': 'Export PDF',
  });
  
  static String get exportExcel => translate({
    'fr': 'Exporter en Excel',
    'en': 'Export Excel',
  });
  
  // ============ TRANSACTIONS ============
  static String get filterTransactions => translate({
    'fr': 'Filtrer les transactions',
    'en': 'Filter Transactions',
  });
  
  static String get category => translate({
    'fr': 'Catégorie',
    'en': 'Category',
  });
  
  static String get revenueCategory => translate({
    'fr': 'Revenus',
    'en': 'Revenue',
  });
  
  static String get marketingCategory => translate({
    'fr': 'Marketing',
    'en': 'Marketing',
  });
  
  static String get saasCategory => translate({
    'fr': 'SaaS',
    'en': 'SaaS',
  });
  
  static String get applyFilters => translate({
    'fr': 'Appliquer les filtres',
    'en': 'Apply Filters',
  });
  
  static String get newTransaction => translate({
    'fr': 'Nouvelle transaction',
    'en': 'New Transaction',
  });
  
  static String get title => translate({
    'fr': 'Titre',
    'en': 'Title',
  });
  
  static String get amountDollar => translate({
    'fr': 'Montant (\$)',
    'en': 'Amount (\$)',
  });
  
  static String get manualEntry => translate({
    'fr': 'Saisie manuelle',
    'en': 'Manual Entry',
  });
  
  static String get justNow => translate({
    'fr': 'À l\'instant',
    'en': 'Just Now',
  });
  
  static String get todayDate => translate({
    'fr': 'Aujourd\'hui, 24 Oct',
    'en': 'Today, Oct 24',
  });
  
  static String get transactionSaved => translate({
    'fr': 'Transaction enregistrée avec succès !',
    'en': 'Transaction saved successfully!',
  });
  
  static String get searchTransactions => translate({
    'fr': 'Rechercher des transactions...',
    'en': 'Search transactions...',
  });
  
  static String get noTransactionsFound => translate({
    'fr': 'Aucune transaction trouvée.',
    'en': 'No transactions found.',
  });
  
  static String get transactionsCount => translate({
    'fr': 'Transactions',
    'en': 'Transactions',
  });
  
  static String get allCategory => translate({
    'fr': 'Tous',
    'en': 'All',
  });
  
  // ============ COMMUNS ============
  static String get loading => translate({
    'fr': 'Chargement...',
    'en': 'Loading...',
  });
  
  static String get error => translate({
    'fr': 'Erreur',
    'en': 'Error',
  });
  
  static String get success => translate({
    'fr': 'Succès',
    'en': 'Success',
  });
  
  static String get noTransactions => translate({
    'fr': 'Aucune transaction',
    'en': 'No transactions',
  });
  
  static String get dontHaveAccount => translate({
    'fr': "Vous n'avez pas de compte ?",
    'en': "Don't have an account?",
  });
  
  static String get alreadyHaveAccount => translate({
    'fr': 'Vous avez déjà un compte ?',
    'en': 'Already have an account?',
  });
  
  static String get signUp => translate({
    'fr': 'Créer un compte',
    'en': 'Sign Up',
  });
  
  static String get signIn => translate({
    'fr': 'Se connecter',
    'en': 'Sign In',
  });
  
  static String get cancel => translate({
    'fr': 'Annuler',
    'en': 'Cancel',
  });
  
  static String get save => translate({
    'fr': 'Enregistrer',
    'en': 'Save',
  });
  
  static String get delete => translate({
    'fr': 'Supprimer',
    'en': 'Delete',
  });
  
  static String get edit => translate({
    'fr': 'Modifier',
    'en': 'Edit',
  });
  
  static String get search => translate({
    'fr': 'Rechercher',
    'en': 'Search',
  });
  
  static String get filter => translate({
    'fr': 'Filtrer',
    'en': 'Filter',
  });
  
  static String get settings => translate({
    'fr': 'Paramètres',
    'en': 'Settings',
  });
  
  static String get logout => translate({
    'fr': 'Se déconnecter',
    'en': 'Logout',
  });
  
  static String get language => translate({
    'fr': 'Langue',
    'en': 'Language',
  });
  
  static String get notifications => translate({
    'fr': 'Notifications',
    'en': 'Notifications',
  });
  
  static String get dailyReminder => translate({
    'fr': 'Rappel quotidien',
    'en': 'Daily Reminder',
  });
  
  static String get reminderHour => translate({
    'fr': 'Heure du rappel',
    'en': 'Reminder Hour',
  });
  
  static String get alertOnGoal => translate({
    'fr': "Alerte d'objectif",
    'en': 'Goal Alert',
  });
  
  static String get alertOnDrop => translate({
    'fr': 'Alerte de baisse',
    'en': 'Drop Alert',
  });
  
  static String get weeklyReport => translate({
    'fr': 'Rapport hebdomadaire',
    'en': 'Weekly Report',
  });
}