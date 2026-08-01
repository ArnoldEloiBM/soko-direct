import 'package:equatable/equatable.dart';

class MarketPrice extends Equatable {
  final String cropType;
  final double averagePrice; // RWF per kg
  final double minPrice;
  final double maxPrice;
  final int listingCount;

  const MarketPrice({
    required this.cropType,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.listingCount,
  });

  @override
  List<Object?> get props => [
    cropType,
    averagePrice,
    minPrice,
    maxPrice,
    listingCount,
  ];
}
