import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/more.pg.dart';
import 'package:bigpay/utils/app_state.util.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more/help',
  );

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      title: l10n.helpTitle,
      child: Column(
        children: [
          ProfileItem(
            onPressed: () {
              final url = Uri.parse(
                'tel:${AppState.data?.help?.phoneNumber}',
              );
              launchUrl(url);
            },
            title: l10n.helpCallUs,
            icon: Icons.phone_outlined,
          ),
          ProfileItem(
            onPressed: () {
              final url = Uri.parse(
                'mailto:${AppState.data?.help?.email}',
              );
              launchUrl(url);
            },
            title: l10n.helpEmailUs,
            icon: Icons.email_outlined,
          ),
          ProfileItem(
            onPressed: () {
              final contact = AppState.data?.help?.whatsApp ?? '';
              if (contact.isEmpty) return;
              final url = contact.startsWith('http')
                  ? Uri.parse(contact)
                  : Uri.parse(
                      'https://wa.me/${contact.replaceAll(RegExp(r'[^0-9]'), '')}',
                    );
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
            title: l10n.helpContactWhatsApp,
            iconSvg: 'assets/img/whatsapp.svg',
          ),
        ],
      ),
    );
  }
}
