/// Plain Dart model, matches the ERD:
/// Wallet
///   balance, provider (MTN/Airtel)
///
/// No Firebase imports here — domain/ stays pure Dart so it's easy to test.
class WalletModel {
  final String userId;
  final double balance;
  final String provider; // "MTN" or "Airtel"

  const WalletModel({
    required this.userId,
    required this.balance,
    required this.provider,
  });

  /// Used when reading from Firestore (or from our fake repository).
  factory WalletModel.fromMap(String userId, Map<String, dynamic> map) {
    return WalletModel(
      userId: userId,
      balance: (map['balance'] as num).toDouble(),
      provider: map['provider'] as String,
    );
  }

  /// Used when writing to Firestore (or logging in the fake repository).
  Map<String, dynamic> toMap() {
    return {'balance': balance, 'provider': provider};
  }

  WalletModel copyWith({double? balance, String? provider}) {
    return WalletModel(
      userId: userId,
      balance: balance ?? this.balance,
      provider: provider ?? this.provider,
    );
  }
}
