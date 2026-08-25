import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/select_toggle.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';

class AddMoMoPage extends StatefulWidget {
  const AddMoMoPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets/add-momo',
  );

  @override
  State<AddMoMoPage> createState() => _AddMoMoPageState();
}

class _AddMoMoPageState extends State<AddMoMoPage> {
  final _networkController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _networkController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      miniTitle: l10n.walletsAddMomoMiniTitle,
      title: l10n.walletsAddMomoTitle,
      subtitle: l10n.walletsAddMomoSubtitle,
      bottomNav: FormButton(
        onPressed: () {},
        enabled: false,
        text: l10n.commonSave,
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormSelectToggleInput(
              label: l10n.walletsChooseNetworkLabel,
              controller: _networkController,
              options: [
                .new(
                  label: 'MTN',
                  value: 'mtn',
                  icon: '',
                ),
                .new(
                  label: 'Telecel',
                  value: 'telecel',
                  icon: '',
                ),
                .new(
                  label: 'AT',
                  value: 'at',
                  icon: '',
                ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            FormInput(
              controller: _phoneController,
              label: l10n.commonPhoneNumberLabel,
            ),
          ],
        ),
      ),
    );
  }
}
