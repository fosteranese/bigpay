import 'package:go_router/go_router.dart';

import 'package:bigpay/constants/response.const.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/ui/pages/app_error.pg.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiaries.pg.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiary_details.pg.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';

List<GoRoute> get rootRoutes => [
  SplashScreenPage.route.toGoRoute(() => const SplashScreenPage()),
  // The error is handed over via `context.go(..., extra: error)`. Fall back to
  // a generic error so a direct/deep link to this route can't crash.
  AppErrorPage.route.toGoRouteWithState(
    (state) => AppErrorPage(
      error: state.extra is DataError
          ? state.extra! as DataError
          : GeneralResponseConst.unknown,
    ),
  ),
  WalkthroughPage.route.toGoRoute(() => const WalkthroughPage()),
  BeneficiariesPage.route.toGoRoute(() => const BeneficiariesPage()),
  BeneficiaryDetailsPage.route.toGoRouteWithState(
    (state) => BeneficiaryDetailsPage(payee: state.extra as Payee?),
  ),
];
