import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;
  final AuthRepository repository;
  final FirebaseMessagingService messagingService;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.repository,
    required this.messagingService,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await login(
      LoginParams(username: event.username, password: event.password),
    );

    User? loggedInUser;
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        loggedInUser = user;
        emit(AuthAuthenticated(user));
      },
    );

    if (loggedInUser != null) {
      final token = messagingService.getSavedToken();
      if (token != null) {
        await repository.updateFcmToken(token);
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logout();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await repository.getCurrentUser();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await repository.clearLocalSession();
    emit(const AuthUnauthenticated());
  }
}
