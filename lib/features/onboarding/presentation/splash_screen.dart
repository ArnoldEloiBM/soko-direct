import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/role/role_cubit.dart';
import '../../listings/presentation/main_shell.dart';
import 'language_screen.dart';

/// Cold-start screen (video step 1). Shows the Soko Direct branding, then:
///   role not chosen yet -> LanguageScreen (first launch)
///   role saved          -> MainShell (returning user)
///
/// Uses Audric's RoleCubit, which restores the saved role from
/// SharedPreferences in its constructor. The short splash delay gives that
/// async load time to finish before we route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final role = context.read<RoleCubit>().state;
    final next = role == UserRole.none
        ? const LanguageScreen()
        // TODO(Samuel): returning users should pass through your auth gate
        // (login screen if signed out) before reaching MainShell.
        : const MainShell();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2E7D32), // Figma green
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 64, color: Color(0xFFB9F6CA)),
              SizedBox(height: 16),
              Text(
                'SOKO DIRECT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Guhuza abahinzi n'abaguzi",
                style: TextStyle(
                  color: Color(0xFFC8E6C9),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Connecting Farmers to Buyers',
                style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 12),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
