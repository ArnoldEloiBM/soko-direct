import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/market_repository.dart';
import 'farmer_dashboard_state.dart';

class FarmerDashboardCubit extends Cubit<FarmerDashboardState> {
  final MarketRepository _repository;
  StreamSubscription? _subscription;

  FarmerDashboardCubit(this._repository) : super(FarmerDashboardInitial());

  /// Subscribes to the live price stream. Every Firestore change re-emits
  /// Loaded, so the UI refreshes by itself — no pull-to-refresh needed.
  void watchPrices() {
    emit(FarmerDashboardLoading());
    _subscription?.cancel();
    _subscription = _repository.watchMarketPrices().listen(
          (prices) => emit(FarmerDashboardLoaded(prices)),
          onError: (Object e) => emit(FarmerDashboardError(e.toString())),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel(); // avoid memory leaks
    return super.close();
  }
}
