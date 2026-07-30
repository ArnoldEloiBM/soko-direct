import 'package:equatable/equatable.dart';

/// A rating one user leaves for another after a completed transaction.
/// Matches the ERD: Rating { id, stars, comment } under Transaction.
class Rating extends Equatable {
  final String id;
  final String transactionId;
  final String raterId; // who is leaving the rating
  final String rateeId; // who is being rated
  final int stars; // 1-5
  final String comment;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.transactionId,
    required this.raterId,
    required this.rateeId,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, transactionId, raterId, rateeId, stars, comment, createdAt];
}
