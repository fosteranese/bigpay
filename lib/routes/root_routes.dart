import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> get rootRoutes => [
      SplashScreenPage.route.toGoRoute(() => const SplashScreenPage()),
      WalkthroughPage.route.toGoRoute(() => const WalkthroughPage()),
    ];
