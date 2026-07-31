import 'package:equatable/equatable.dart';

/// The two kinds of accounts Soko Direct supports.
enum UserRole { farmer, buyer }

/// The authenticated user, merged from Firebase Auth + their Firestore
/// profile document (see ERD: `users/{uid}`).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.district,
    this.rating = 0,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? district;
  final double rating;

  @override
  List<Object?> get props => [id, name, email, role, phone, district, rating];
}
