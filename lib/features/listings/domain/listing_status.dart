/// Firestore `status` field values for the `listings` collection.
enum ListingStatus {
  active('active'),
  withOffers('with_offers'),
  sold('sold');

  const ListingStatus(this.firestoreValue);

  final String firestoreValue;

  static ListingStatus fromFirestore(String value) {
    return ListingStatus.values.firstWhere(
      (status) => status.firestoreValue == value,
      orElse: () => ListingStatus.active,
    );
  }
}
