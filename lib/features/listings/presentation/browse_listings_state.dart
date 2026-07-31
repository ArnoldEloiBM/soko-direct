import 'package:equatable/equatable.dart';

import '../domain/listing.dart';

enum BrowseListingsStatus { loading, loaded, error }

class BrowseListingsState extends Equatable {
  const BrowseListingsState({
    this.status = BrowseListingsStatus.loading,
    this.listings = const [],
    this.errorMessage,
  });

  final BrowseListingsStatus status;
  final List<Listing> listings;
  final String? errorMessage;

  BrowseListingsState copyWith({
    BrowseListingsStatus? status,
    List<Listing>? listings,
    String? errorMessage,
  }) {
    return BrowseListingsState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, listings, errorMessage];
}
