import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/auth_routes.dart';
import 'package:bigpay/routes/root_routes.dart';
import 'package:bigpay/ui/pages/auth/forgot_secure_phrase/done_forgot_secure_phrase.pg.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: DoneForgotSecurePhrasePage.routeName,
    routes: [
      ...rootRoutes,
      authRoute,
    ],
  );
}
