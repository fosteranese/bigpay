import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/ui/components/bottom_nav_bar.dart';

/// Hosts the tab branches and the bottom nav bar, switching branches on tap.
///
/// The umb-style wiring: a [StatefulShellRoute] builds this with a
/// [StatefulNavigationShell]; the shell renders the active branch as [body],
/// exposes the active tab via `currentIndex`, and `goBranch` switches tabs
/// while preserving each tab's own navigation stack.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Let the branch content run under the floating nav bar.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: NeumorphicBottomNav(
          selectedIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            // Always land on the tab's main page — reset the branch to its root
            // on every tap, not just when re-tapping the active tab.
            initialLocation: true,
          ),
        ),
      ),
    );
  }
}
