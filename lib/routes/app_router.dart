import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/auth_routes.dart';
import 'package:bigpay/routes/kyc_routes.dart';
import 'package:bigpay/routes/more_routes.dart';
import 'package:bigpay/routes/process_flow_routes.dart';
import 'package:bigpay/routes/root_routes.dart';
import 'package:bigpay/routes/wallet_routes.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';

/// Lets a page react to being revealed again after a route above it is popped
/// (via `RouteAware.didPopNext`). A [State] subscribes in `didChangeDependencies`
/// and unsubscribes in `dispose`.
final appRouteObserver = RouteObserver<PageRoute<dynamic>>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: SplashScreenPage.route.path,
    observers: [appRouteObserver],
    routes: [
      ...rootRoutes,
      authRoute,
      kycRoute,
      processFlowRoute,
      walletRoute,
      moreRoute,
    ],
  );
}

extension AppRouterNavigation on GoRouter {
  /// Pops the navigation stack until the route named [name] is on top, or the
  /// stack can pop no further (a no-op if it's already on top).
  ///
  /// Route names come from [PageRouteDefinition.name], so pass a page's route:
  /// `AppRouter.router.popUntilNamed(DashboardPage.route.name)`.
  void popUntilNamed(String name) {
    routerDelegate.navigatorKey.currentState?.popUntil(
      (route) => route.settings.name == name,
    );
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
    FutureOr<bool> Function(BuildContext, GoRouterState)? onExit,
  }) {
    return GoRoute(
      name: name,
      path: nested ? subPath : path,
      builder: (context, state) => page(),
      onExit: onExit,
    );
  }

  /// Variant for pages that need routing data — e.g. reading `state.extra`.
  GoRoute toGoRouteWithState(
    Widget Function(GoRouterState state) page, {
    bool nested = false,
    FutureOr<bool> Function(BuildContext, GoRouterState)? onExit,
  }) {
    return GoRoute(
      name: name,
      path: nested ? subPath : path,
      builder: (context, state) => page(state),
      onExit: onExit,
    );
  }
}
