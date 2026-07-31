import '../domain/offer.dart';

enum OfferSubmitStatus { initial, submitting, success, failure }

class OfferState {
  final List<Offer> offers;
  final OfferSubmitStatus submitStatus;
  final String? errorMessage;

  const OfferState({
    this.offers = const [],
    this.submitStatus = OfferSubmitStatus.initial,
    this.errorMessage,
  });

  OfferState copyWith({
    List<Offer>? offers,
    OfferSubmitStatus? submitStatus,
    String? errorMessage,
  }) {
    return OfferState(
      offers: offers ?? this.offers,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage,
    );
  }
}
