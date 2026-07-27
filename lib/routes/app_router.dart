import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/auth_routes.dart';
import 'package:bigpay/routes/kyc_routes.dart';
import 'package:bigpay/routes/main_shell_routes.dart';
import 'package:bigpay/routes/root_routes.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';

final appRouteObserver = RouteObserver<PageRoute<dynamic>>();

/// The app's top-level navigator — the one the bottom-nav shell lives inside.
/// A route pushed onto it (via `rootNavigator: true`) covers the shell, so it
/// shows full-screen with no bottom nav bar.
final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashScreenPage.route.path,
    observers: [appRouteObserver],
    routes: [
      ...rootRoutes,
      authRoute,
      kycRoute,
      mainShellRoute,
    ],
  );
}

extension AppRouterNavigation on GoRouter {
  void popUntilNamed(String name) {
    while (name != AppRouter.router.state.path && AppRouter.router.canPop()) {
      AppRouter.router.pop();
    }
  }
}

class PageRouteDefinition {
  final String path;
  final String subPath;
  final String name;

  PageRouteDefinition({
    required this.path,
    String? subPath,
    String? name,
  }) : subPath = subPath ?? path.split('/').last,
       name = name ?? path.split('/').last;
}

extension GoRouteX on PageRouteDefinition {
  GoRoute toGoRoute(
    Widget Function() page, {
    bool nested = false,
    bool rootNavigator = false,
    FutureOr<bool> Function(BuildContext, GoRouterState)? onExit,
  }) {
    return GoRoute(
      name: name,
      path: nested ? subPath : path,
      // Pushed onto the root navigator, so it covers the bottom-nav shell.
      parentNavigatorKey: rootNavigator ? rootNavigatorKey : null,
      builder: (context, state) => page(),
      onExit: onExit,
    );
  }

  /// Variant for pages that need routing data — e.g. reading `state.extra`.
  GoRoute toGoRouteWithState(
    Widget Function(GoRouterState state) page, {
    bool nested = false,
    bool rootNavigator = false,
    FutureOr<bool> Function(BuildContext, GoRouterState)? onExit,
  }) {
    return GoRoute(
      name: name,
      path: nested ? subPath : path,
      parentNavigatorKey: rootNavigator ? rootNavigatorKey : null,
      builder: (context, state) => page(state),
      onExit: onExit,
    );
  }
}
