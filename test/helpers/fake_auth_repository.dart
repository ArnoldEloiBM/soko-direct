import 'package:soko_direct/features/auth/domain/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.userId = 'test-user'});

  final String userId;

  @override
  String? get currentUserId => userId;

  @override
  Future<String> ensureSignedIn() async => userId;
}
