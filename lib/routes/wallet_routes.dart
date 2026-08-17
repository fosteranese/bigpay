import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/wallets/add_card.pg.dart';
import 'package:bigpay/ui/pages/wallets/momo/add_momo.pg.dart';
import 'package:bigpay/ui/pages/wallets/momo/otp_momo.pg.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';
import 'package:bigpay/ui/pages/wallets/wallets.pg.dart';

GoRoute get walletRoute => GoRoute(
  name: WalletsPage.route.name,
  path: WalletsPage.route.path,
  redirect: (context, state) => null,
  builder: (context, state) => WalletsPage(),
  routes: [
    AddCardPage.route.toGoRoute(
      () => const AddCardPage(),
      nested: true,
    ),
    VirtualWalletPage.route.toGoRouteWithState(
      (state) => VirtualWalletPage(account: state.extra as Account?),
      nested: true,
    ),
    AddMoMoPage.route.toGoRoute(
      () => const AddMoMoPage(),
      nested: true,
    ),
    OtpMoMoPage.route.toGoRoute(
      () => const OtpMoMoPage(),
      nested: true,
    ),
  ],
);
