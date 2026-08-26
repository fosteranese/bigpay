import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/ghana_card/auto_ghana_card_verification_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/l10n/flow_steps.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/step_progress.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:bigpay/utils/validator.util.dart';

class ContactInfoKycPage extends StatefulWidget {
  const ContactInfoKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/contact',
  );

  @override
  State<ContactInfoKycPage> createState() => _ContactInfoKycPageState();
}

class _ContactInfoKycPageState extends State<ContactInfoKycPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailAddressFocusNode = FocusNode();
  final _streetAddressFocusNode = FocusNode();
  final _digitalAddressFocusNode = FocusNode();

  final _emailAddressController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _digitalAddressController = TextEditingController();

  final _canSubmit = ValueNotifier(false);
  ExecuteProcessEvent? mainEvent;

  @override
  void dispose() {
    _emailAddressFocusNode.dispose();
    _streetAddressFocusNode.dispose();
    _digitalAddressFocusNode.dispose();

    _emailAddressController.dispose();
    _streetAddressController.dispose();
    _digitalAddressController.dispose();
    _canSubmit.dispose();

    super.dispose();
  }

  void _onChanged(String value) {
    final canSubmit =
        _emailAddressController.text.isNotEmpty &&
        _digitalAddressController.text.isNotEmpty &&
        _emailAddressController.text.isNotEmpty;

    _canSubmit.value = canSubmit;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProcessListener<Null>(
      event: () => mainEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading && !snapshot.isSilent && !snapshot.isCached) {
          MessageUtil.displayLoading(context);
          return;
        } else if (!snapshot.isSilent && !snapshot.isCached) {
          MessageUtil.close(context);
        }

        if (snapshot.isSuccessful) {
          if (Kyc.route != null) {
            AppRouter.router.popUntilNamed(
              Kyc.route!.path,
            );
            MessageUtil.displaySuccessFullDialog(
              context,
              title: l10n.kycVerificationSuccessTitle,
              message: snapshot.response?.message ?? '',
              onOk: () {
                Future.delayed(Duration(seconds: 1), () {
                  Kyc.onSuccess!.call();
                  Kyc.clear();
                });
              },
            );
            return;
          }

          return;
        }

        if (snapshot.hasError) {
          MessageUtil.displayErrorDialog(
            context,
            title: l10n.kycVerificationFailedTitle,
            message: snapshot.error!.message,
          );

          return;
        }
      },
      child: MainLayout(
        title: l10n.kycContactInfoTitle,
        titleStyle: context.display2,
        stepIndicator: StepProgress(
          currentStep: 2,
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
          key: _formKey,
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              FormInput(
                focusNode: _emailAddressFocusNode,
                controller: _emailAddressController,
                label: l10n.profileEmailAddressLabel,
                validator: Validator.emailValidator(
                  l10n.validationEmailInvalid,
                ),
                onChanged: _onChanged,
                next: (value) {
                  _streetAddressFocusNode.requestFocus();
                },
              ),
              const SizedBox(height: 15),
              FormInput(
                focusNode: _streetAddressFocusNode,
                controller: _streetAddressController,
                label: l10n.kycStreetAddressLabel,
                onChanged: _onChanged,
                next: (value) {
                  _digitalAddressFocusNode.requestFocus();
                },
              ),
              const SizedBox(height: 15),
              FormInput(
                focusNode: _digitalAddressFocusNode,
                controller: _digitalAddressController,
                label: l10n.kycDigitalAddressLabel,
                onChanged: _onChanged,
                next: (value) {
                  FocusScope.of(context).unfocus();
                },
                textInputAction: .done,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    mainEvent = context.dispatchProcess(
      AutoGhanaCardVerificationAction(
        payload: AutoGhanaCardVerificationActionPayload(
          cardNumber: Kyc.ghanaCardNumber,
          picture: AppState.currentUser?.profilePicture ?? '',
          email: _emailAddressController.text.trim(),
          streetAddress: _streetAddressController.text.trim(),
          digitalAddress: _digitalAddressController.text.trim(),
        ),
      ),
    );
  }
}
