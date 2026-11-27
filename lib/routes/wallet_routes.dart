import 'package:go_router/go_router.dart';

import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/data/models/account/source.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/wallets/add_card.pg.dart';
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
      rootNavigator: true,
    ),
    VirtualWalletPage.route.toGoRouteWithState(
      (state) {
        final extra = state.extra;
        // The wallets list passes a (account, source) pair; the dashboard's
        // "View details" passes just the account.
        if (extra is (Account, Source)) {
          return VirtualWalletPage(account: extra.$1, source: extra.$2);
        }
        return VirtualWalletPage(account: extra as Account?);
      },
      nested: true,
      // Full-screen, above the tab bar — like AddCardPage and receipts.
      rootNavigator: true,
    ),
  ],
);
