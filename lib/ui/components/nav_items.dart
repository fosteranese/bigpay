import 'package:flutter/material.dart';

/// The 5 main tabs, shared between [NeumorphicBottomNav] (compact width) and
/// [SideNavRail] (tablet/desktop width) so they can't drift out of sync.
///
/// Order MUST match the branch order in `mainShellRoute`.
const navBarItems = <({IconData icon, String label})>[
  (icon: Icons.home_outlined, label: 'Home'),
  (icon: Icons.account_balance_wallet_outlined, label: 'Wallets'),
  (icon: Icons.description_outlined, label: 'Services'),
  (icon: Icons.history, label: 'History'),
  (icon: Icons.more_horiz, label: 'More'),
];
