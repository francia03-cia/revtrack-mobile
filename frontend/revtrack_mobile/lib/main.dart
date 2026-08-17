import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/navigation/presentation/screens/main_navigation.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const RevTrackApp());
}

class RevTrackApp extends StatefulWidget {
  const RevTrackApp({super.key});

  @override
  State<RevTrackApp> createState() => _RevTrackAppState();
}

class _RevTrackAppState extends State<RevTrackApp> {
  final GlobalKey _materialKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          )..add(AuthCheckStatus()),
        ),
      ],
      child: MaterialApp(
        key: _materialKey,
        title: 'RevTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainNavigation();
            } else if (state is AuthUnauthenticated) {
              return const LoginScreen();
            } else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }

  void _changeLanguage(String langCode) {
    setState(() {
      AppStrings.changeLanguage(langCode);
    });
  }
}