import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/ui/components/app_sidebar.dart';
import 'package:bigpay/ui/components/bottom_nav_bar.dart';
import 'package:bigpay/ui/components/side_nav_rail.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:bigpay/utils/app_state.util.dart';

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
    // Book mode gets the same chrome as any other window this wide —
    // an unfolded/half-opened foldable at expanded+ width has the same
    // real estate as a tablet or desktop, so it should look like one,
    // sidebar included, not fall back to phone-style bottom nav.
    if (context.isExpanded) {
      return ValueListenableBuilder<bool>(
        valueListenable: AppState.splitDetailOpenNotifier,
        builder: (context, splitDetailOpen, _) {
          // A tab-root page (Services, Wallets, History) is showing its own
          // master+detail split — give it the whole window the same way a
          // pushed split view (Complaints, Beneficiaries) already gets it,
          // instead of leaving the sidebar competing for width alongside
          // two more panes.
          if (splitDetailOpen) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: navigationShell,
            );
          }

          final hinge = context.isBookMode ? context.hingeBounds : null;
          // In book mode, align the sidebar to the physical hinge instead
          // of its own fixed width — the left panel should read as "the
          // sidebar", not "the sidebar plus some unexplained gap before the
          // hinge". Falls back to the fixed width whenever there's no real
          // hinge to align to (MainShell is the outermost shell, so unlike
          // MasterDetailLayout it never needs to correct for preceding
          // chrome — there isn't any here).
          final sidebarWidth = hinge != null && hinge.left >= 200
              ? hinge.left
              : null;
          final gapWidth = hinge != null
              ? math.max(hinge.width, 1.0)
              : null;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                AppSidebar(
                  selectedIndex: navigationShell.currentIndex,
                  onTap: _goBranch,
                  width: sidebarWidth ?? 248,
                ),
                if (gapWidth != null)
                  Container(width: gapWidth, color: context.scaffoldBg),
                Expanded(child: navigationShell),
              ],
            ),
          );
        },
      );
    }

    if (context.isMedium) {
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
