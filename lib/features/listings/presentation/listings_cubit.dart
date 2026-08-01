import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/friendly_error.dart';
import '../domain/current_user_repository.dart';
import '../domain/listing.dart';
import '../domain/listing_input.dart';
import '../domain/listings_domain.dart';
import 'listings_state.dart';

class ListingsCubit extends Cubit<ListingsState> {
  ListingsCubit({
    required ListingsDomain domain,
    required CurrentUserRepository authRepository,
  }) : _domain = domain,
       _authRepository = authRepository,
       super(const ListingsState());

  final ListingsDomain _domain;
  final CurrentUserRepository _authRepository;
  StreamSubscription<List<Listing>>? _subscription;

  Future<void> startWatching() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final sellerId = await _authRepository.ensureSignedIn();
      await _subscription?.cancel();
      _subscription = _domain
          .watchUserListings(sellerId)
          .listen(
            (listings) {
              emit(
                state.copyWith(
                  listings: listings,
                  isLoading: false,
                  action: ListingsAction.none,
                  clearMessages: true,
                ),
              );
            },
            onError: (Object error) {
              emit(
                state.copyWith(
                  isLoading: false,
                  action: ListingsAction.none,
                  errorMessage: _messageFor(error),
                ),
              );
            },
          );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _messageFor(error)));
    }
  }

  Future<bool> createListing(ListingInput input) async {
    emit(state.copyWith(action: ListingsAction.creating, clearMessages: true));
    try {
      final sellerId = await _authRepository.ensureSignedIn();
      await _domain.createListing(sellerId: sellerId, input: input);
      emit(
        state.copyWith(
          action: ListingsAction.none,
          successMessage: 'Listing posted successfully.',
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          action: ListingsAction.none,
          errorMessage: _messageFor(error),
        ),
      );
      return false;
    }
  }

  Future<bool> updateListing({
    required String listingId,
    required ListingInput input,
  }) async {
    emit(state.copyWith(action: ListingsAction.updating, clearMessages: true));
    try {
      final sellerId = await _authRepository.ensureSignedIn();
      final updated = await _domain.updateListing(
        listingId: listingId,
        sellerId: sellerId,
        input: input,
      );
      emit(
        state.copyWith(
          action: ListingsAction.none,
          successMessage: updated.isSoldOut
              ? 'Listing marked as sold — your stock is empty.'
              : 'Listing updated successfully.',
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          action: ListingsAction.none,
          errorMessage: _messageFor(error),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    emit(state.copyWith(action: ListingsAction.deleting, clearMessages: true));
    try {
      final sellerId = await _authRepository.ensureSignedIn();
      await _domain.deleteListing(listingId: listingId, sellerId: sellerId);
      emit(
        state.copyWith(
          action: ListingsAction.none,
          successMessage: 'Listing deleted.',
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          action: ListingsAction.none,
          errorMessage: _messageFor(error),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  String _messageFor(Object error) {
    if (error is ListingsDomainException) {
      return error.message;
    }
    return friendlyErrorMessage(error);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
