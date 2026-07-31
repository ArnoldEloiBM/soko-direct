/// User-facing, already-friendly error message for the transactions
/// feature — same convention as `auth/domain/failures/auth_failure.dart`.
class TransactionFailure implements Exception {
  const TransactionFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
