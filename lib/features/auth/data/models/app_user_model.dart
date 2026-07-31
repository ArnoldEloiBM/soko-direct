import '../../domain/entities/app_user.dart';

/// Adds Firestore (de)serialization on top of the plain [AppUser] entity.
/// Kept separate from the domain entity so `domain/` never imports
/// anything Firestore-shaped.
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.phone,
    super.district,
    super.rating,
  });

  factory AppUserModel.fromMap(String id, Map<String, dynamic> map) {
    return AppUserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] == 'farmer' ? UserRole.farmer : UserRole.buyer,
      phone: map['phone'] as String?,
      district: map['district'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role == UserRole.farmer ? 'farmer' : 'buyer',
      'phone': phone,
      'district': district,
      'rating': rating,
    };
  }
}
