import 'package:bigpay/routes/history_routes.dart';
import 'package:bigpay/routes/more_routes.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/routes/process_flow_routes.dart';
import 'package:bigpay/routes/wallet_routes.dart';
import 'package:bigpay/ui/components/main_shell.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';

/// The tabbed main area — Home · Wallets · Services · History · More — wired the
/// umb way: a [StatefulShellRoute.indexedStack] with one branch per tab, each
/// keeping its own navigation stack, switched by the bottom nav in [MainShell].
///
/// Branch order MUST match the item order in `NeumorphicBottomNav`.
final mainShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MainShell(navigationShell: navigationShell),
  branches: [
    // 0 · Home
    StatefulShellBranch(
      routes: [
        DashboardPage.route.toGoRoute(() => const DashboardPage()),
      ],
    ),
    // 1 · Wallets
    StatefulShellBranch(routes: [walletRoute]),
    // 2 · Services
    StatefulShellBranch(routes: [processFlowRoute]),
    // 3 · History
    StatefulShellBranch(
      routes: [
        historyRoute,
      ],
    ),
    // 4 · More
    StatefulShellBranch(
      routes: [
        moreRoute,
      ],
    ),
  ],
);
