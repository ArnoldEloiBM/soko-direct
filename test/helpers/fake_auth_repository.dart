import 'package:soko_direct/core/role/role_cubit.dart';
import 'package:soko_direct/features/auth/domain/entities/app_user.dart';
import 'package:soko_direct/features/auth/domain/failures/auth_failure.dart';
import 'package:soko_direct/features/auth/domain/repositories/auth_repository.dart';

/// In-memory stand-in for [AuthRepository] so Cubit/widget tests never
/// need a real Firebase project. Configure [loginError]/[registerError]
/// to make the next call fail with a given friendly message.
///
/// `authStateChanges` intentionally never emits: `AuthCubit` only reacts
/// to it for cold-start session restore, which these tests don't
/// exercise — every test drives the Cubit through its methods instead,
/// same as the real app does after a user action.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.loginError, this.registerError});

  String? loginError;
  String? registerError;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String district,
    required UserRole role,
  }) async {
    if (registerError != null) throw AuthFailure(registerError!);
    return AppUser(
      id: 'test-uid',
      name: name,
      email: email,
      role: role,
      phone: phone,
      district: district,
    );
  }

  @override
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (loginError != null) throw AuthFailure(loginError!);
    return AppUser(
      id: 'test-uid',
      name: 'Test User',
      email: email,
      role: UserRole.farmer,
    );
  }

  @override
  Future<AppUser> signInWithGoogle({required UserRole role}) async {
    return AppUser(
      id: 'google-uid',
      name: 'Google User',
      email: 'google@example.com',
      role: role,
    );
  }

  @override
  Future<void> logout() async {}
}
