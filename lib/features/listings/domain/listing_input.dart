import 'package:equatable/equatable.dart';

/// Values collected from the create/edit form before domain validation.
class ListingInput extends Equatable {
  const ListingInput({
    required this.cropType,
    required this.pricePerKg,
    required this.quantityKg,
    required this.availableFrom,
    required this.location,
    this.photoPath,
    this.existingPhotoUrl,
  });

  final String cropType;
  final double pricePerKg;
  final double quantityKg;
  final DateTime availableFrom;
  final String location;
  final String? photoPath;
  final String? existingPhotoUrl;

  @override
  List<Object?> get props => [
    cropType,
    pricePerKg,
    quantityKg,
    availableFrom,
    location,
    photoPath,
    existingPhotoUrl,
  ];
}
