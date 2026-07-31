import '../domain/offer.dart';

enum OfferSubmitStatus { initial, submitting, success, failure }

enum OfferActionStatus { idle, updating, success, failure }

class OfferState {
  const OfferState({
    this.offers = const [],
    this.submitStatus = OfferSubmitStatus.initial,
    this.actionStatus = OfferActionStatus.idle,
    this.errorMessage,
    this.actionMessage,
  });

  final List<Offer> offers;
  final OfferSubmitStatus submitStatus;
  final OfferActionStatus actionStatus;
  final String? errorMessage;
  final String? actionMessage;

  List<Offer> get pendingOffers =>
      offers.where((offer) => offer.isPending).toList();

  OfferState copyWith({
    List<Offer>? offers,
    OfferSubmitStatus? submitStatus,
    OfferActionStatus? actionStatus,
    String? errorMessage,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return OfferState(
      offers: offers ?? this.offers,
      submitStatus: submitStatus ?? this.submitStatus,
      actionStatus: clearActionMessage
          ? OfferActionStatus.idle
          : (actionStatus ?? this.actionStatus),
      errorMessage: clearActionMessage ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
    );
  }
}
