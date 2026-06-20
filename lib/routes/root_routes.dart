import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:bigpay/ui/pages/wallets/add_card.pg.dart';
import 'package:bigpay/ui/pages/wallets/momo/add_momo.pg.dart';
import 'package:bigpay/ui/pages/wallets/momo/otp_momo.pg.dart';
import 'package:bigpay/ui/pages/wallets/wallets.pg.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> get rootRoutes => [
  SplashScreenPage.route.toGoRoute(() => const SplashScreenPage()),
  WalkthroughPage.route.toGoRoute(() => const WalkthroughPage()),
  DashboardPage.route.toGoRoute(() => const DashboardPage()),
  WalletsPage.route.toGoRoute(() => const WalletsPage()),
  AddCardPage.route.toGoRoute(() => const AddCardPage()),
  AddMoMoPage.route.toGoRoute(() => const AddMoMoPage()),
  OtpMoMoPage.route.toGoRoute(() => const OtpMoMoPage()),
];
