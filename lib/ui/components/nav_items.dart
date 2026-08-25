import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';

/// The 5 main tabs, shared between [NeumorphicBottomNav] (compact width) and
/// [SideNavRail] (tablet/desktop width) so they can't drift out of sync.
///
/// Order MUST match the branch order in `mainShellRoute`.
List<({IconData icon, String label})> navBarItems(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [
    (icon: Icons.home_outlined, label: l10n.navHome),
    (icon: Icons.account_balance_wallet_outlined, label: l10n.walletsTitle),
    (icon: Icons.description_outlined, label: l10n.dashboardServicesHeader),
    (icon: Icons.history, label: l10n.navHistory),
    (icon: Icons.more_horiz, label: l10n.navMore),
  ];
}
