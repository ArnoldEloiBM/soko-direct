import 'package:firebase_auth/firebase_auth.dart';

import '../domain/current_user_repository.dart';

/// Real users always reach the listings feature already signed in via
/// AuthGate, so this never falls back to anonymous auth — it just reads
/// whoever FirebaseAuth already has signed in.
class FirebaseCurrentUserRepository implements CurrentUserRepository {
  FirebaseCurrentUserRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<String> ensureSignedIn() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    return user.uid;
  }
}
