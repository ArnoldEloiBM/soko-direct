import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/rating.dart';
import '../domain/rating_repository.dart';
import 'rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  final RatingRepository _repository;
  StreamSubscription<List<Rating>>? _subscription;

  RatingCubit({required RatingRepository repository})
      : _repository = repository,
        super(const RatingState());

  /// Starts listening to ratings left for [userId]. Call this once
  /// when the profile/rating screen opens.
  void watchRatingsForUser(String userId) {
    _subscription?.cancel();
    _subscription = _repository.watchRatingsForUser(userId).listen(
      (ratings) => emit(state.copyWith(ratings: ratings)),
      onError: (_) =>
          emit(state.copyWith(errorMessage: 'Could not load ratings.')),
    );
  }

  Future<void> submitRating({
    required String transactionId,
    required String raterId,
    required String rateeId,
    required int stars,
    required String comment,
  }) async {
    emit(state.copyWith(submitStatus: RatingSubmitStatus.submitting));
    try {
      final rating = Rating(
        id: '${transactionId}_$raterId',
        transactionId: transactionId,
        raterId: raterId,
        rateeId: rateeId,
        stars: stars,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await _repository.submitRating(rating);
      emit(state.copyWith(submitStatus: RatingSubmitStatus.success));
    } catch (_) {
      emit(state.copyWith(
        submitStatus: RatingSubmitStatus.failure,
        errorMessage: 'Could not submit rating. Try again.',
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
