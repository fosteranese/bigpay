import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiaries.pg.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/history/history.pg.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/pages/more/account.pg.dart';
import 'package:bigpay/ui/pages/more/account_details.pg.dart';
import 'package:bigpay/ui/pages/more/security.pg.dart';
import 'package:bigpay/ui/pages/pin_auth.pg.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';

List<GoRoute> get rootRoutes => [
  SplashScreenPage.route.toGoRoute(() => const SplashScreenPage()),
  WalkthroughPage.route.toGoRoute(() => const WalkthroughPage()),
  DashboardPage.route.toGoRoute(() => const DashboardPage()),
  HistoryPage.route.toGoRoute(() => const HistoryPage()),
  TransactionDetailsPage.route.toGoRoute(() => const TransactionDetailsPage()),
  MyProfilePage.route.toGoRoute(() => const MyProfilePage()),
  ProfileDetailsPage.route.toGoRoute(() => const ProfileDetailsPage()),
  PinAuthPage.route.toGoRoute(() => const PinAuthPage()),
  SecurityPage.route.toGoRoute(() => const SecurityPage()),
  BeneficiariesPage.route.toGoRoute(() => const BeneficiariesPage()),
];
