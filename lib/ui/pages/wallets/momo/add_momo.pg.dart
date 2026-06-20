import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/select_toggle.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
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
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      miniTitle: 'Add MoMo Wallet',
      title: 'Add Mobile Money Wallet',
      subtitle:
          'Securely connect your mobile money wallet for instant wallet top-ups and seamless payments.',
      bottomNav: FormButton(
        onPressed: () {},
        enabled: false,
        text: 'Save',
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormSelectToggleInput(
              label: 'Choose Network',
              controller: TextEditingController(),
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
            const SizedBox(height: 20),
            FormInput(
              controller: TextEditingController(),
              label: 'Phone Number',
            ),
          ],
        ),
      ),
    );
  }
}
