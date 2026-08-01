import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/friendly_error.dart';
import '../domain/listing.dart';
import '../domain/listings_repository.dart';
import 'browse_listings_state.dart';

/// Separate from [ListingsCubit] on purpose: that one watches *the
/// signed-in user's own* listings (My Listings) and only ever has one
/// active subscription at a time. Buyer browsing needs to watch *all*
/// listings simultaneously without stomping on that subscription, so it
/// gets its own small cubit over the same [ListingsRepository].
class BrowseListingsCubit extends Cubit<BrowseListingsState> {
  BrowseListingsCubit({required ListingsRepository repository})
    : _repository = repository,
      super(const BrowseListingsState()) {
    _subscription = _repository.watchAllListings().listen(
      (listings) => emit(
        state.copyWith(status: BrowseListingsStatus.loaded, listings: listings),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: BrowseListingsStatus.error,
          errorMessage: friendlyErrorMessage(error),
        ),
      ),
    );
  }

  final ListingsRepository _repository;
  late final StreamSubscription<List<Listing>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
