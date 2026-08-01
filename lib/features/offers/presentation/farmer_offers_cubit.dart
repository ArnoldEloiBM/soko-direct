import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/offer_repository_impl.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

enum FarmerOffersStatus { initial, loading, loaded, error }

class FarmerOffersState {
  const FarmerOffersState({
    this.status = FarmerOffersStatus.initial,
    this.offers = const [],
    this.errorMessage,
  });

  final FarmerOffersStatus status;
  final List<Offer> offers;
  final String? errorMessage;

  List<Offer> get pendingOffers =>
      offers.where((offer) => offer.isPending).toList();

  /// One entry per listing that still has at least one pending offer.
  Map<String, List<Offer>> get pendingByListing {
    final grouped = <String, List<Offer>>{};
    for (final offer in pendingOffers) {
      grouped.putIfAbsent(offer.listingId, () => []).add(offer);
    }
    return grouped;
  }

  FarmerOffersState copyWith({
    FarmerOffersStatus? status,
    List<Offer>? offers,
    String? errorMessage,
  }) {
    return FarmerOffersState(
      status: status ?? this.status,
      offers: offers ?? this.offers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FarmerOffersCubit extends Cubit<FarmerOffersState> {
  FarmerOffersCubit({OfferRepository? repository})
    : _repository = repository ?? OfferRepositoryImpl(),
      super(const FarmerOffersState());

  final OfferRepository _repository;
  StreamSubscription<List<Offer>>? _subscription;

  void watchForFarmer(String farmerId) {
    if (farmerId.isEmpty) return;
    emit(state.copyWith(status: FarmerOffersStatus.loading));
    _subscription?.cancel();
    _subscription = _repository.watchOffersForFarmer(farmerId).listen(
      (offers) => emit(
        state.copyWith(
          status: FarmerOffersStatus.loaded,
          offers: offers,
        ),
      ),
      onError: (_) => emit(
        state.copyWith(
          status: FarmerOffersStatus.error,
          errorMessage: 'Could not load incoming offers.',
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
