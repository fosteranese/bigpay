import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return MainLayout(
      title: 'Help',
      child: Column(
        children: [
          ProfileItem(
            onPressed: () {
              final url = Uri.parse(
                'tel:${AppState.data?.help?.phoneNumber}',
              );
              launchUrl(url);
            },
            title: 'Call Us',
            icon: Icons.phone_outlined,
          ),
          ProfileItem(
            onPressed: () {
              final url = Uri.parse(
                'mailto:${AppState.data?.help?.email}',
              );
              launchUrl(url);
            },
            title: 'Email Us',
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
            title: 'Contact us via WhatsApp',
            iconSvg: 'assets/img/whatsapp.svg',
          ),
        ],
      ),
    );
  }
}
