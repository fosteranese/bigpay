import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/kyc/kyc_validation_result.dart';
import 'package:bigpay/models/actions/ghana_card/auto_ghana_card_verification_action.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
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

  /// The validated identity, set once [AutoGhanaCardVerificationAction]
  /// succeeds. Non-null flips the page from the form to the identity preview.
  KycValidationResult? _result;
  String? _successMessage;

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
        _streetAddressController.text.isNotEmpty &&
        _digitalAddressController.text.isNotEmpty;

    _canSubmit.value = canSubmit;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProcessListener<KycValidationResult>(
      event: () => mainEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading && !snapshot.isSilent && !snapshot.isCached) {
          MessageUtil.displayLoading(context);
          return;
        } else if (!snapshot.isSilent && !snapshot.isCached) {
          MessageUtil.close(context);
        }

        if (snapshot.isSuccessful) {
          // Show the validated identity on this page before completing —
          // _finish() runs the original pop/onSuccess once the user confirms.
          setState(() {
            _result = snapshot.data ?? const KycValidationResult();
            _successMessage = snapshot.response?.message;
          });
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
        bottomSize: 60,
        bottomNav: _result != null
            ? FormButton(
                onPressed: _finish,
                text: l10n.commonConfirm,
              )
            : ValueListenableBuilder(
                valueListenable: _canSubmit,
                builder: (context, value, child) {
                  return FormButton(
                    enabled: value,
                    onPressed: _continue,
                    text: l10n.commonContinue,
                  );
                },
              ),
        child: _result != null ? _buildPreview(l10n) : _buildForm(l10n),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Form(
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
          const SizedBox(height: Spacing.lg),
          FormInput(
            focusNode: _streetAddressFocusNode,
            controller: _streetAddressController,
            label: l10n.kycStreetAddressLabel,
            onChanged: _onChanged,
            next: (value) {
              _digitalAddressFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: Spacing.lg),
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
    );
  }

  /// The validated identity echoed back by the verification — Name,
  /// Nationality, Gender from the response's `data` prop.
  Widget _buildPreview(AppLocalizations l10n) {
    final result = _result!;
    final rows = <(String, String)>[
      if (result.name?.trim().isNotEmpty ?? false)
        (l10n.kycVerifiedName, result.name!),
      if (result.nationality?.trim().isNotEmpty ?? false)
        (l10n.kycVerifiedNationality, result.nationality!),
      if (result.gender?.trim().isNotEmpty ?? false)
        (l10n.kycVerifiedGender, result.gender!),
    ];

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if ((_successMessage ?? '').isNotEmpty) ...[
          Text(_successMessage!, style: context.smallDetails),
          const SizedBox(height: Spacing.lg),
        ],
        Container(
          padding: const .all(20),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: .circular(12),
          ),
          child: Column(
            mainAxisSize: .min,
            children: [
              for (final (index, (title, value)) in rows.indexed) ...[
                TransactionDetailsItem(title: title, value: value),
                if (index != rows.length - 1) Divider(color: context.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Completes KYC after the identity preview — mirrors the original
  /// post-success navigation, now gated behind the user's confirmation.
  void _finish() {
    final l10n = AppLocalizations.of(context)!;
    if (Kyc.route != null) {
      AppRouter.router.popUntilNamed(Kyc.route!.path);
      MessageUtil.displaySuccessFullDialog(
        context,
        title: l10n.kycVerificationSuccessTitle,
        message: _successMessage ?? '',
        onOk: () {
          Future.delayed(const Duration(seconds: 1), () {
            Kyc.onSuccess?.call();
            Kyc.clear();
          });
        },
      );
      return;
    }
    Kyc.onSuccess?.call();
    Kyc.clear();
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    mainEvent = context.dispatchProcess(
      AutoGhanaCardVerificationAction(
        payload: AutoGhanaCardVerificationActionPayload(
          cardNumber: Kyc.ghanaCardNumber,
          picture: Kyc.passportPicture,
          email: _emailAddressController.text.trim(),
          streetAddress: _streetAddressController.text.trim(),
          digitalAddress: _digitalAddressController.text.trim(),
        ),
      ),
    );
  }
}
