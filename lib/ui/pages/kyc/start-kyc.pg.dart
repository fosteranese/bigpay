import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/step_progress.dart';

class StartKycPage extends StatefulWidget {
  const StartKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/start',
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
    _phoneNumberController.dispose();
    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      title: l10n.kycGhanaCardInfoTitle,
      titleStyle: context.display2,
      stepIndicator: StepProgress(
        currentStep: 0,
        totalSteps: 3,
        labels: l10n.kycSteps,
      ),
      bottomSize: 60,
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: _continue,
            text: l10n.commonContinue,
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
              next: (_) => _continue,
              onInvalid: _onInvalid,
              onSuccess: _onSuccess,
              textInputAction: .done,
            ),
          ],
        ),
      ),
    );
  }

  void _onSuccess(_) {
    _canSubmit.value = true;
  }

  void _onInvalid(_) {
    _canSubmit.value = false;
  }

  void _continue() {
    Kyc.ghanaCardNumber = _phoneNumberController.text.trim();
    FocusScope.of(context).unfocus();

    AppRouter.router.push(InfoKycPage.route.path);
  }
}
