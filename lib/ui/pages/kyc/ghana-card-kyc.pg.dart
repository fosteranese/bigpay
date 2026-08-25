import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class GhanaCardKycPage extends StatefulWidget {
  const GhanaCardKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/ghana-card',
  );

  @override
  State<GhanaCardKycPage> createState() => _GhanaCardKycPageState();
}

class _GhanaCardKycPageState extends State<GhanaCardKycPage> {
  final _ghanaCardFocusNode = FocusNode();
  final _issueDateFocusNode = FocusNode();
  final _expiryDateFocusNode = FocusNode();

  final _ghanaCardController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _ghanaCardFocusNode.dispose();
    _issueDateFocusNode.dispose();
    _expiryDateFocusNode.dispose();

    _ghanaCardController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _canSubmit.dispose();

    super.dispose();
  }

  void _onChanged(String value) {
    final canSubmit =
        _ghanaCardController.text.isNotEmpty &&
        _issueDateController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty;

    _canSubmit.value = canSubmit;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      title: l10n.kycGhanaCardInfoTitle,
      titleStyle: context.display2,
      bottomSize: 60,
      bottomNav: ValueListenableBuilder(
        valueListenable: _canSubmit,
        builder: (context, value, child) {
          return FormButton(
            enabled: value,
            onPressed: () {},
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
              focusNode: _ghanaCardFocusNode,
              controller: _ghanaCardController,
              next: (value) {
                _issueDateFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: FormDateInput(
                    focusNode: _issueDateFocusNode,
                    controller: _issueDateController,
                    label: l10n.kycIssueDateLabel,
                    onChanged: (date) {
                      _onChanged(_issueDateController.text);
                    },
                    next: (value) {
                      _expiryDateFocusNode.requestFocus();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: FormDateInput(
                    focusNode: _expiryDateFocusNode,
                    controller: _expiryDateController,
                    label: l10n.kycExpiryDateLabel,
                    onChanged: (date) {
                      _onChanged(_expiryDateController.text);
                    },
                    next: (value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
