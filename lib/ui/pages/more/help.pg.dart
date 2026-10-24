import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/more.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
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
  /// The server sends several contacts as one comma-separated string
  /// (e.g. "+233591824050, +233591823963").
  List<String> _split(String? raw) => (raw ?? '')
      .split(RegExp(r'[,;]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  /// Opens a single contact directly; with several, lets the user pick one
  /// from a bottom sheet first.
  void _contact(
    String title,
    IconData icon,
    String? raw,
    void Function(String value) open,
  ) {
    final values = _split(raw);
    if (values.isEmpty) return;
    if (values.length == 1) return open(values.single);

    final cap = contentCapWidth(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      constraints: cap == double.infinity
          ? null
          : BoxConstraints(maxWidth: cap),
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const .all(20),
        padding: const .all(10),
        decoration: BoxDecoration(
          color: ctx.cardBg,
          borderRadius: .circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .start,
                children: [
                  Flexible(child: Text(title, style: ctx.header1)),
                  IconButton.filled(
                    tooltip: l10n.commonClose,
                    style: IconButton.styleFrom(
                      backgroundColor: ctx.divider,
                      fixedSize: const Size(44, 44),
                    ),
                    onPressed: () => ctx.pop(),
                    icon: Icon(Icons.close, size: 17, color: ctx.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final value in values)
                ListTile(
                  leading: Icon(icon, color: ctx.textPrimary),
                  title: Text(value, style: ctx.p1),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: ctx.textSecondary,
                  ),
                  onTap: () {
                    ctx.pop();
                    open(value);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final help = AppState.data?.help;
    return MainLayout(
      title: l10n.helpTitle,
      child: Column(
        children: [
          ProfileItem(
            onPressed: () => _contact(
              l10n.helpCallUs,
              Icons.phone_outlined,
              help?.phoneNumber,
              (phone) => launchUrl(
                Uri.parse('tel:${phone.replaceAll(RegExp(r'\s'), '')}'),
              ),
            ),
            title: l10n.helpCallUs,
            icon: Icons.phone_outlined,
          ),
          ProfileItem(
            onPressed: () => _contact(
              l10n.helpEmailUs,
              Icons.email_outlined,
              help?.email,
              (email) => launchUrl(Uri.parse('mailto:$email')),
            ),
            title: l10n.helpEmailUs,
            icon: Icons.email_outlined,
          ),
          ProfileItem(
            onPressed: () => _contact(
              l10n.helpContactWhatsApp,
              Icons.chat_outlined,
              help?.whatsApp,
              (contact) => launchUrl(
                contact.startsWith('http')
                    ? Uri.parse(contact)
                    : Uri.parse(
                        'https://wa.me/${contact.replaceAll(RegExp(r'[^0-9]'), '')}',
                      ),
                mode: LaunchMode.externalApplication,
              ),
            ),
            title: l10n.helpContactWhatsApp,
            iconSvg: 'assets/img/whatsapp.svg',
          ),
        ],
      ),
    );
  }
}
