import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../wallet/presentation/wallet_screen.dart';
import 'my_listings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Wallet brings its own AppBar/Scaffold, so skip the green header
    // here to avoid showing two title bars stacked on top of each other.
    final showHeader = _currentIndex != 3;

    return Scaffold(
      body: Column(
        children: [
          if (showHeader)
            _ScreenHeader(
              title: _titleForIndex(_currentIndex),
              subtitle: _subtitleForIndex(_currentIndex),
            ),
          Expanded(child: _bodyForIndex(_currentIndex)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _titleForIndex(int index) {
    return switch (index) {
      0 => 'Home',
      1 => 'My Listings',
      2 => 'Browse',
      3 => 'Wallet',
      4 => 'Profile',
      _ => 'Soko Direct',
    };
  }

  String _subtitleForIndex(int index) {
    return switch (index) {
      0 => 'Welcome back',
      1 => 'Manage your produce',
      2 => 'Find fresh produce nearby',
      3 => 'Your payments',
      4 => 'Your account',
      _ => '',
    };
  }

  Widget _bodyForIndex(int index) {
    return switch (index) {
      1 => const MyListingsScreen(),
      3 => const WalletScreen(),
      _ => Center(
        child: Text(
          '${_titleForIndex(index)} coming soon',
          style: const TextStyle(color: AppColors.subtitleGrey),
        ),
      ),
    };
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
