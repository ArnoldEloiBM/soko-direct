import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/offer.dart';
import '../domain/offer_repository.dart';
import 'offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  OfferCubit({required OfferRepository repository})
    : _repository = repository,
      super(const OfferState());

  final OfferRepository _repository;
  StreamSubscription<List<Offer>>? _subscription;

  /// Starts listening to offers made on [listingId]. Call this once
  /// when the listing detail screen opens (so the farmer sees new
  /// offers coming in live).
  void watchOffersForListing(String listingId) {
    _subscription?.cancel();
    _subscription = _repository
        .watchOffersForListing(listingId)
        .listen(
          (offers) => emit(
            state.copyWith(offers: offers, clearActionMessage: true),
          ),
          onError: (_) => emit(
            state.copyWith(errorMessage: 'Could not load offers.'),
          ),
        );
  }

  Future<void> submitOffer({
    required String listingId,
    required String buyerId,
    required String farmerId,
    required String cropType,
    required double pricePerKg,
    required int quantityKg,
  }) async {
    emit(
      state.copyWith(
        submitStatus: OfferSubmitStatus.submitting,
        clearActionMessage: true,
      ),
    );
    try {
      final offer = Offer(
        id: '${listingId}_${buyerId}_${DateTime.now().millisecondsSinceEpoch}',
        listingId: listingId,
        buyerId: buyerId,
        farmerId: farmerId,
        cropType: cropType,
        pricePerKg: pricePerKg,
        quantityKg: quantityKg,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await _repository.submitOffer(offer);
      emit(state.copyWith(submitStatus: OfferSubmitStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          submitStatus: OfferSubmitStatus.failure,
          errorMessage: 'Could not submit offer. Try again.',
        ),
      );
    }
  }

  Future<void> respondToOffer({
    required String offerId,
    required bool accept,
  }) async {
    emit(state.copyWith(actionStatus: OfferActionStatus.updating));
    try {
      await _repository.updateOfferStatus(
        offerId: offerId,
        status: accept ? 'accepted' : 'rejected',
      );
      emit(
        state.copyWith(
          actionStatus: OfferActionStatus.success,
          actionMessage: accept ? 'Offer accepted.' : 'Offer declined.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: OfferActionStatus.failure,
          errorMessage: 'Could not update offer. Try again.',
        ),
      );
    }
  }

  void resetSubmitStatus() {
    emit(state.copyWith(submitStatus: OfferSubmitStatus.initial));
  }

  void clearActionMessage() {
    emit(state.copyWith(clearActionMessage: true));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
