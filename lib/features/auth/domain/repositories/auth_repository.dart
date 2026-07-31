import '../../../../core/role/role_cubit.dart';
import '../entities/app_user.dart';

/// The "rules" for authentication. No Firebase types appear here — only
/// the data layer (see `data/repositories/firebase_auth_repository.dart`)
/// is allowed to know that Firebase exists.
abstract class AuthRepository {
  /// Emits the signed-in user (with their Firestore profile merged in),
  /// or `null` when signed out. Cubits subscribe to this instead of
  /// polling, so login/logout propagate to the whole app instantly.
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String district,
    required UserRole role,
  });

  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  });

  /// Signs in with Google. `role` is only used the first time this
  /// Google account signs in (i.e. it doubles as registration) — for a
  /// returning user, their existing Firestore role wins.
  Future<AppUser> signInWithGoogle({required UserRole role});

  Future<void> logout();
}
