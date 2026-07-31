import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/language/language_cubit.dart';
import '../../../core/role/role_cubit.dart';
import '../../listings/presentation/main_shell.dart';

/// Lets the user pick Farmer or Buyer. The choice is:
///   1) saved via Audric's RoleCubit (SharedPreferences — 3rd persisted
///      setting, together with language and theme)
///   2) later written to the Firestore `users` doc during Samuel's
///      registration flow — we only pass it along from here.
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  Future<void> _choose(BuildContext context, UserRole role) async {
    await context.read<RoleCubit>().setRole(role);
    if (!context.mounted) return;
    // TODO(Samuel): route to registration/login instead once auth is ready.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the language changes, so all labels are localized.
    final language = context.watch<LanguageCubit>().state;
    final strings =
        AppStrings(language == AppLanguage.kinyarwanda ? 'rw' : 'en');

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.eco, size: 48, color: Color(0xFFB9F6CA)),
                  const SizedBox(height: 16),
                  Text(
                    strings.get('chooseRole'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _RoleCard(
                    icon: Icons.agriculture,
                    title: strings.get('farmer'),
                    subtitle: strings.get('farmerSubtitle'),
                    onTap: () => _choose(context, UserRole.farmer),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.shopping_basket,
                    title: strings.get('buyer'),
                    subtitle: strings.get('buyerSubtitle'),
                    onTap: () => _choose(context, UserRole.buyer),
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF4C9A52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF2E7D32),
                child: Icon(icon, color: const Color(0xFFB9F6CA), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFC8E6C9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
