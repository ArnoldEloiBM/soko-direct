/// Narrow contract the listings feature needs: who is the signed-in
/// seller right now. Deliberately not named `AuthRepository` — that name
/// belongs to the real, full auth feature (registration/login/Google/
/// logout, see `features/auth/domain/repositories/auth_repository.dart`)
/// which this delegates to.
abstract class CurrentUserRepository {
  Future<String> ensureSignedIn();

  String? get currentUserId;
}
