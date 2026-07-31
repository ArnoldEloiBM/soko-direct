import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';

/// Farmer/Buyer picker shown on the register screen (and on the login
/// screen, since a first-time Google sign-in also needs a role).
class RoleToggle extends StatelessWidget {
  const RoleToggle({super.key, required this.role, required this.onChanged});

  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(
          value: UserRole.farmer,
          label: Text('Farmer'),
          icon: Icon(Icons.agriculture_outlined),
        ),
        ButtonSegment(
          value: UserRole.buyer,
          label: Text('Buyer'),
          icon: Icon(Icons.storefront_outlined),
        ),
      ],
      selected: {role},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
