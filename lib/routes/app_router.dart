import 'package:bigpay/ui/pages/kyc/info-kyc.pg.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/auth_routes.dart';
import 'package:bigpay/routes/root_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: InfoKycPage.route.path,
    routes: [
      ...rootRoutes,
      authRoute,
    ],
  );
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
  GoRoute toGoRoute(Widget Function() page, {bool nested = false}) {
    return GoRoute(
      name: name,
      path: nested ? subPath : path,
      builder: (context, state) => page(),
    );
  }
}
