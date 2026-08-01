import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two theme states our app can be in.
enum AppThemeMode { light, dark }

/// A Cubit is a simplified Bloc: you call a method (like `toggleTheme`)
/// instead of adding an "event". Same architecture, less boilerplate.
///
/// Pattern to copy for YOUR feature:
///   1. Define your states (here: AppThemeMode)
///   2. Extend `Cubit<YourStateType>`
///   3. Write methods that do work, then `emit(newState)`
///   4. Never put Firebase/SharedPreferences calls in the UI — only here
///      or in a Repository this Cubit talks to.
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit() : super(AppThemeMode.light) {
    _loadSavedTheme();
  }

  static const _themeKey = 'app_theme_mode';

  /// Runs once when the app starts: restores the saved theme.
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    emit(saved == 'dark' ? AppThemeMode.dark : AppThemeMode.light);
  }

  /// Called from the UI (e.g. a Switch or button).
  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    emit(newMode); // 1. update the UI immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      newMode == AppThemeMode.dark ? 'dark' : 'light',
    ); // 2. persist it so it survives app restart
  }
}
