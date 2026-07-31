import 'rating.dart';

/// The rules for rating data. No Firebase import here on purpose —
/// the domain layer never knows where data comes from.
abstract class RatingRepository {
  Future<void> submitRating(Rating rating);
  Stream<List<Rating>> watchRatingsForUser(String userId);
}
