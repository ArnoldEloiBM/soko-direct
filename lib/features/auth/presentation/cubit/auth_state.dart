import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthStatus {
  /// We haven't checked yet whether a session exists (splash/cold start).
  unknown,
  authenticating,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;

  /// Set right after a failed action; screens show it once (e.g. a
  /// SnackBar) and it is cleared on the next action so it never
  /// re-appears on rebuild.
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
