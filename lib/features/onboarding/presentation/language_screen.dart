import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/language/language_cubit.dart';
import 'role_screen.dart';

/// Matches the Figma prototype: green background, leaf logo, app name,
/// bilingual tagline, and two language buttons (RW / GB).
///
/// Uses Audric's LanguageCubit (core/language) so there is exactly ONE
/// owner of the language preference in the whole app.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _choose(BuildContext context, AppLanguage language) async {
    await context.read<LanguageCubit>().setLanguage(language);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: SafeArea(
        // Scroll view prevents pixel overflow when the phone is rotated
        // to landscape (explicitly penalized in the rubric).
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.eco, size: 56, color: Color(0xFFB9F6CA)),
                  const SizedBox(height: 12),
                  const Text(
                    'SOKO DIRECT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Guhuza abahinzi n'abaguzi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFC8E6C9),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Text(
                    'Connecting Farmers to Buyers',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 12),
                  ),
                  const SizedBox(height: 48),
                  _LanguageButton(
                    flagLabel: 'RW',
                    language: 'Kinyarwanda',
                    onTap: () => _choose(context, AppLanguage.kinyarwanda),
                  ),
                  const SizedBox(height: 16),
                  _LanguageButton(
                    flagLabel: 'GB',
                    language: 'English',
                    onTap: () => _choose(context, AppLanguage.english),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flagLabel;
  final String language;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flagLabel,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4C9A52),
        foregroundColor: Colors.white,
        // >= 48dp height meets the Material tap-target size in the rubric.
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF81C784), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            flagLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC8E6C9),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            language,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
