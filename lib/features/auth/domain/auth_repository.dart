/// Auth contract used by features that need the current user id.
abstract class AuthRepository {
  Future<String> ensureSignedIn();

  String? get currentUserId;
}
