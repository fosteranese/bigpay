import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';

class StartKycPage extends StatefulWidget {
  const StartKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/start-kyc',
  );

  @override
  State<StartKycPage> createState() => _StartKycPageState();
}

class _StartKycPageState extends State<StartKycPage> {
  final _phoneNumberFocusNode = FocusNode();
  final _phoneNumberController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Ghana Card Information',
      titleStyle: AppTypography.display2,
      bottomSize: 60,
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: () {},
            text: 'Continue',
          );
        },
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            GhanaCardInput(
              focusNode: _phoneNumberFocusNode,
              controller: _phoneNumberController,
              next: (_) {},
              onInvalid: (value) {},
              onSuccess: _onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged(_) {
    _canSubmit.value = _phoneNumberController.text.isNotEmpty;
  }
}
