import 'package:flutter/material.dart';

/// Temporary stand-in for the real MainShell (Audric's
/// audric-listing-rating branch, not yet merged into main). Splash and
/// role selection need somewhere to route returning/just-onboarded
/// users, so this exists purely to keep the app compiling and
/// navigable until that branch lands and replaces it.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Main app shell — coming soon')),
    );
  }
}
