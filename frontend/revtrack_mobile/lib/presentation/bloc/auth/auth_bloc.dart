import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revtrack_mobile/data/models/user.dart';
import 'package:revtrack_mobile/data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  AuthLogin({required this.email, required this.password});
}

class AuthRegister extends AuthEvent {
  final String name;
  final String email;
  final String password;
  AuthRegister({required this.name, required this.email, required this.password});
}

class AuthLogout extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (isAuthenticated) {
      try {
        final user = await _authRepository.getCurrentUser();
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Future<void> _onLogin(
  //   AuthLogin event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     final user = await _authRepository.login(
  //       event.email,
  //       event.password,
  //     );
  //     emit(AuthAuthenticated(user: user));
  //   } catch (e) {
  //     emit(AuthError(message: e.toString()));
  //   }
  // }

  // Future<void> _onLogin(
  //   AuthLogin event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   print('⏳ AUTH BLOC: Loading...');
    
  //   try {
  //     final user = await _authRepository.login(
  //       event.email,
  //       event.password,
  //     );
      
  //     print('✅ AUTH BLOC: User logged in: ${user.email}');
  //     print('📦 AUTH BLOC: User data: ${user.toJson()}');
      
  //     emit(AuthAuthenticated(user: user));
  //   } catch (e) {
  //     print('❌ AUTH BLOC: Error: $e');
  //     emit(AuthError(message: e.toString()));
  //   }
  // }

  Future<void> _onLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    print('⏳ AUTH BLOC: Loading...');
    
    try {
      final user = await _authRepository.login(
        event.email,
        event.password,
      );
      
      print('✅ AUTH BLOC: User logged in: ${user.email}');
      emit(AuthAuthenticated(user: user));
      
    } catch (e) {
      // 🔥 EXTRAIRE LE MESSAGE D'ERREUR
      String errorMessage = e.toString();
      // Nettoyer le message
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      
      print('❌ AUTH BLOC: Error: $errorMessage');
      
      // 🔥 TRANSMETTRE L'ERREUR À L'UI
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onRegister(
    AuthRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}