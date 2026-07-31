import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/role/role_cubit.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/screens/profile_tab.dart';
import '../../dashboard/presentation/farmer_dashboard_body.dart';
import '../../wallet/presentation/wallet_screen.dart';
import 'my_listings_screen.dart';
import 'pages/buyer_dashboard.dart';

enum _ShellTab { home, listings, browse, wallet, profile }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  UserRole _resolveRole(BuildContext context) {
    final authRole = context.read<AuthCubit>().state.user?.role;
    if (authRole != null && authRole != UserRole.none) {
      return authRole;
    }
    return context.read<RoleCubit>().state;
  }

  List<_ShellTab> _tabsForRole(UserRole role) {
    if (role == UserRole.farmer) {
      return const [
        _ShellTab.home,
        _ShellTab.listings,
        _ShellTab.browse,
        _ShellTab.wallet,
        _ShellTab.profile,
      ];
    }
    return const [
      _ShellTab.home,
      _ShellTab.browse,
      _ShellTab.wallet,
      _ShellTab.profile,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = _resolveRole(context);
    final tabs = _tabsForRole(role);
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }
    final currentTab = tabs[_currentIndex];

    // Wallet and Browse bring their own AppBar/Scaffold, so skip the
    // green header here to avoid showing two title bars stacked on top
    // of each other.
    final showHeader =
        currentTab != _ShellTab.browse && currentTab != _ShellTab.wallet;

    return Scaffold(
      body: Column(
        children: [
          if (showHeader)
            _ScreenHeader(
              title: _titleForTab(currentTab),
              subtitle: _subtitleForTab(currentTab),
            ),
          Expanded(child: _bodyForTab(currentTab)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: tabs.map(_destinationForTab).toList(),
      ),
    );
  }

  NavigationDestination _destinationForTab(_ShellTab tab) {
    return switch (tab) {
      _ShellTab.home => const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      _ShellTab.listings => const NavigationDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: 'Listings',
      ),
      _ShellTab.browse => const NavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        label: 'Browse',
      ),
      _ShellTab.wallet => const NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Wallet',
      ),
      _ShellTab.profile => const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    };
  }

  String _titleForTab(_ShellTab tab) {
    return switch (tab) {
      _ShellTab.home => 'Home',
      _ShellTab.listings => 'My Listings',
      _ShellTab.browse => 'Browse',
      _ShellTab.wallet => 'Wallet',
      _ShellTab.profile => 'Profile',
    };
  }

  String _subtitleForTab(_ShellTab tab) {
    return switch (tab) {
      _ShellTab.home => 'Welcome back',
      _ShellTab.listings => 'Manage your produce',
      _ShellTab.browse => 'Find fresh produce nearby',
      _ShellTab.wallet => 'Your payments',
      _ShellTab.profile => 'Your account',
    };
  }

  Widget _bodyForTab(_ShellTab tab) {
    return switch (tab) {
      _ShellTab.home => const FarmerDashboardBody(),
      _ShellTab.listings => const MyListingsScreen(),
      _ShellTab.browse => const BuyerDashboardPage(),
      _ShellTab.wallet => const WalletScreen(),
      _ShellTab.profile => const ProfileTab(),
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
