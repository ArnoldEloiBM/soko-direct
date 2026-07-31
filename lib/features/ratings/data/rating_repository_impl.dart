import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/rating.dart';
import '../domain/rating_repository.dart';

/// Talks to Firestore. This is the only file in the ratings feature
/// that imports cloud_firestore.
class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _firestore;

  RatingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ratingsRef =>
      _firestore.collection('ratings');

  @override
  Future<void> submitRating(Rating rating) async {
    await _ratingsRef.doc(rating.id).set({
      'transactionId': rating.transactionId,
      'raterId': rating.raterId,
      'rateeId': rating.rateeId,
      'stars': rating.stars,
      'comment': rating.comment,
      'createdAt': Timestamp.fromDate(rating.createdAt),
    });
  }

  @override
  Stream<List<Rating>> watchRatingsForUser(String userId) {
    return _ratingsRef
        .where('rateeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Rating(
                id: doc.id,
                transactionId: data['transactionId'] as String,
                raterId: data['raterId'] as String,
                rateeId: data['rateeId'] as String,
                stars: data['stars'] as int,
                comment: data['comment'] as String,
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            }).toList());
  }
}
