import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/ui/components/bottom_nav_bar.dart';
import 'package:bigpay/ui/components/side_nav_rail.dart';
import 'package:bigpay/ui/theme/responsive.dart';

/// Hosts the tab branches and the bottom nav bar, switching branches on tap.
///
/// The umb-style wiring: a [StatefulShellRoute] builds this with a
/// [StatefulNavigationShell]; the shell renders the active branch as [body],
/// exposes the active tab via `currentIndex`, and `goBranch` switches tabs
/// while preserving each tab's own navigation stack.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) => navigationShell.goBranch(
    index,
    // Always land on the tab's main page — reset the branch to its root
    // on every tap, not just when re-tapping the active tab.
    initialLocation: true,
  );

  @override
  Widget build(BuildContext context) {
    if (context.isTabletOrLarger) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            SideNavRail(
              selectedIndex: navigationShell.currentIndex,
              onTap: _goBranch,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      // Let the branch content run under the floating nav bar.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: NeumorphicBottomNav(
          selectedIndex: navigationShell.currentIndex,
          onTap: _goBranch,
        ),
      ),
    );
  }
}
