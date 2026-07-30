import 'package:equatable/equatable.dart';

import '../../domain/entities/listing.dart';

enum ListingsAction { none, creating, updating, deleting }

class ListingsState extends Equatable {
  const ListingsState({
    this.listings = const [],
    this.isLoading = true,
    this.action = ListingsAction.none,
    this.errorMessage,
    this.successMessage,
  });

  final List<Listing> listings;
  final bool isLoading;
  final ListingsAction action;
  final String? errorMessage;
  final String? successMessage;

  bool get isBusy => action != ListingsAction.none;

  ListingsState copyWith({
    List<Listing>? listings,
    bool? isLoading,
    ListingsAction? action,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ListingsState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      action: action ?? this.action,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    listings,
    isLoading,
    action,
    errorMessage,
    successMessage,
  ];
}
