import 'package:equatable/equatable.dart';

import '../domain/market_price_model.dart';

abstract class FarmerDashboardState extends Equatable {
  const FarmerDashboardState();

  @override
  List<Object?> get props => [];
}

class FarmerDashboardInitial extends FarmerDashboardState {}

class FarmerDashboardLoading extends FarmerDashboardState {}

class FarmerDashboardLoaded extends FarmerDashboardState {
  final List<MarketPrice> prices;
  const FarmerDashboardLoaded(this.prices);

  @override
  List<Object?> get props => [prices];
}

class FarmerDashboardError extends FarmerDashboardState {
  final String message;
  const FarmerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
