/// A user-facing, already-friendly error message. Repositories are
/// responsible for translating raw Firebase/Google errors into one of
/// these before they ever reach the Cubit or UI — screens should never
/// need to know what a `FirebaseAuthException` code means.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
