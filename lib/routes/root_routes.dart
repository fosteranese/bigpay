import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> get rootRoutes => [
      GoRoute(
        path: SplashScreenPage.routeName,
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: WalkthroughPage.routeName,
        builder: (context, state) => const WalkthroughPage(),
      ),
    ];
