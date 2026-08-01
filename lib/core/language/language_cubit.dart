import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The languages the app supports.
enum AppLanguage { english, kinyarwanda }

/// Same pattern as ThemeCubit: emit immediately, persist after.
/// Screens (e.g. Armstrong's language selection screen) only ever
/// call `setLanguage` — they never touch SharedPreferences directly.
class LanguageCubit extends Cubit<AppLanguage> {
  LanguageCubit() : super(AppLanguage.english) {
    _loadSavedLanguage();
  }

  static const _languageKey = 'app_language';

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    emit(saved == 'rw' ? AppLanguage.kinyarwanda : AppLanguage.english);
  }

  Future<void> setLanguage(AppLanguage language) async {
    emit(language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _languageKey,
      language == AppLanguage.kinyarwanda ? 'rw' : 'en',
    );
  }
}
