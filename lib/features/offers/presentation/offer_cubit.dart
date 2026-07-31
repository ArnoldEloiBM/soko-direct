import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';
import 'offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _repository;
  StreamSubscription<List<Offer>>? _subscription;

  OfferCubit({required OfferRepository repository})
    : _repository = repository,
      super(const OfferState());

  ///Starts listening to offers made on [listingId]. Call this once
  ///when the listing detail screen opens (so the farmer sees new
  ///offers coming in live).
  void watchOffersForListing(String listingId) {
    _subscription?.cancel();
    _subscription = _repository
        .watchOffersForListing(listingId)
        .listen(
          (offers) => emit(state.copyWith(offers: offers)),
          onError: (_) =>
              emit(state.copyWith(errorMessage: 'Could not load offers.')),
        );
  }

  Future<void> submitOffer({
    required String listingId,
    required String buyerId,
    required String farmerId,
    required double pricePerKg,
    required int quantityKg,
  }) async {
    emit(state.copyWith(submitStatus: OfferSubmitStatus.submitting));
    try {
      final offer = Offer(
        id: '${listingId}_${buyerId}_${DateTime.now().millisecondsSinceEpoch}',
        listingId: listingId,
        buyerId: buyerId,
        farmerId: farmerId,
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
