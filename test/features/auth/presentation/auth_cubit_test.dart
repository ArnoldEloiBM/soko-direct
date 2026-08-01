import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/core/role/role_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_state.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits [authenticating, authenticated] when login succeeds',
      build: () => AuthCubit(authRepository: FakeAuthRepository()),
      act: (cubit) => cubit.loginWithEmail(
        email: 'farmer@example.com',
        password: 'password123',
      ),
      expect: () => [
        const AuthState(status: AuthStatus.authenticating),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.email, 'user.email', 'farmer@example.com'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [authenticating, unauthenticated with friendly error] when login fails',
      build: () => AuthCubit(
        authRepository: FakeAuthRepository(
          loginError: 'Incorrect email or password.',
        ),
      ),
      act: (cubit) =>
          cubit.loginWithEmail(email: 'farmer@example.com', password: 'wrong'),
      expect: () => [
        const AuthState(status: AuthStatus.authenticating),
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Incorrect email or password.',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits authenticated with the chosen role after registration',
      build: () => AuthCubit(authRepository: FakeAuthRepository()),
      act: (cubit) => cubit.registerWithEmail(
        name: 'Jane Farmer',
        email: 'jane@example.com',
        password: 'password123',
        phone: '0788000000',
        district: 'Musanze',
        role: UserRole.farmer,
      ),
      expect: () => [
        const AuthState(status: AuthStatus.authenticating),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.role, 'user.role', UserRole.farmer),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout resets state to unauthenticated',
      build: () => AuthCubit(authRepository: FakeAuthRepository()),
      act: (cubit) async {
        await cubit.loginWithEmail(
          email: 'farmer@example.com',
          password: 'password123',
        );
        await cubit.logout();
      },
      expect: () => [
        const AuthState(status: AuthStatus.authenticating),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.authenticated,
        ),
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );
  });
}
