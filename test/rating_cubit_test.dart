import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:soko_direct/features/ratings/domain/rating.dart';
import 'package:soko_direct/features/ratings/domain/rating_repository.dart';
import 'package:soko_direct/features/ratings/presentation/rating_cubit.dart';
import 'package:soko_direct/features/ratings/presentation/rating_state.dart';

class FakeRatingRepository implements RatingRepository {
  bool shouldFail = false;
  Rating? lastSubmitted;

  @override
  Future<void> submitRating(Rating rating) async {
    if (shouldFail) throw Exception('network error');
    lastSubmitted = rating;
  }

  @override
  Stream<List<Rating>> watchRatingsForUser(String userId) {
    return Stream.value([
      Rating(
        id: '1',
        transactionId: 't1',
        raterId: 'u1',
        rateeId: userId,
        stars: 4,
        comment: 'Good trade',
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
  }
}

void main() {
  late FakeRatingRepository repository;

  setUp(() {
    repository = FakeRatingRepository();
  });

  group('RatingCubit', () {
    blocTest<RatingCubit, RatingState>(
      'emits ratings list when watchRatingsForUser is called',
      build: () => RatingCubit(repository: repository),
      act: (cubit) => cubit.watchRatingsForUser('user1'),
      expect: () => [
        isA<RatingState>().having(
          (s) => s.ratings.length,
          'ratings length',
          1,
        ),
      ],
    );

    blocTest<RatingCubit, RatingState>(
      'emits submitting then success on successful submitRating',
      build: () => RatingCubit(repository: repository),
      act: (cubit) => cubit.submitRating(
        transactionId: 't1',
        raterId: 'u1',
        rateeId: 'u2',
        stars: 5,
        comment: 'Great!',
      ),
      expect: () => [
        isA<RatingState>().having(
          (s) => s.submitStatus,
          'status',
          RatingSubmitStatus.submitting,
        ),
        isA<RatingState>().having(
          (s) => s.submitStatus,
          'status',
          RatingSubmitStatus.success,
        ),
      ],
    );

    blocTest<RatingCubit, RatingState>(
      'emits submitting then failure when repository throws',
      build: () {
        repository.shouldFail = true;
        return RatingCubit(repository: repository);
      },
      act: (cubit) => cubit.submitRating(
        transactionId: 't1',
        raterId: 'u1',
        rateeId: 'u2',
        stars: 5,
        comment: 'Great!',
      ),
      expect: () => [
        isA<RatingState>().having(
          (s) => s.submitStatus,
          'status',
          RatingSubmitStatus.submitting,
        ),
        isA<RatingState>().having(
          (s) => s.submitStatus,
          'status',
          RatingSubmitStatus.failure,
        ),
      ],
    );
  });
}
