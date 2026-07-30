import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Matches the ERD: User is either a farmer or a buyer.
/// `none` means the person hasn't picked yet (first app launch).
enum UserRole { none, farmer, buyer }

/// Same pattern as ThemeCubit and LanguageCubit: emit immediately,
/// persist after. Armstrong's role selection screen only calls
/// `setRole` — it never touches SharedPreferences directly.
class RoleCubit extends Cubit<UserRole> {
  RoleCubit() : super(UserRole.none) {
    _loadSavedRole();
  }

  static const _roleKey = 'app_user_role';

  Future<void> _loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_roleKey);
    switch (saved) {
      case 'farmer':
        emit(UserRole.farmer);
      case 'buyer':
        emit(UserRole.buyer);
      default:
        emit(UserRole.none);
    }
  }

  Future<void> setRole(UserRole role) async {
    emit(role);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
  }
}
