import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/role/role_cubit.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Screens only ever call methods on this Cubit — never the repository,
/// never Firebase — see the "Screen -> Cubit -> Repository -> Firebase"
/// rule in ARCHITECTURE.md.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    _authSubscription = _authRepository.authStateChanges.listen(
      _onAuthChanged,
      onError: (_) => emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
      ),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _authSubscription;

  void _onAuthChanged(AppUser? user) {
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String district,
    required UserRole role,
  }) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final user = await _authRepository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        phone: phone,
        district: district,
        role: role,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final user = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> signInWithGoogle({required UserRole role}) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final user = await _authRepository.signInWithGoogle(role: role);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
