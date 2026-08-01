import 'package:equatable/equatable.dart';
import '../domain/rating.dart';

enum RatingSubmitStatus { idle, submitting, success, failure }

class RatingState extends Equatable {
  final List<Rating> ratings;
  final RatingSubmitStatus submitStatus;
  final String? errorMessage;

  const RatingState({
    this.ratings = const [],
    this.submitStatus = RatingSubmitStatus.idle,
    this.errorMessage,
  });

  double get averageStars {
    if (ratings.isEmpty) return 0;
    final total = ratings.fold<int>(0, (sum, r) => sum + r.stars);
    return total / ratings.length;
  }

  RatingState copyWith({
    List<Rating>? ratings,
    RatingSubmitStatus? submitStatus,
    String? errorMessage,
  }) {
    return RatingState(
      ratings: ratings ?? this.ratings,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [ratings, submitStatus, errorMessage];
}
