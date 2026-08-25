import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';

class PersonalInfoKycPage extends StatefulWidget {
  const PersonalInfoKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/personal',
  );

  @override
  State<PersonalInfoKycPage> createState() => _PersonalInfoKycPageState();
}

class _PersonalInfoKycPageState extends State<PersonalInfoKycPage> {
  final _firstNameFocusNode = FocusNode();
  final _middleNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailAddressFocusNode = FocusNode();
  final _birthDateFocusNode = FocusNode();
  final _genderFocusNode = FocusNode();
  final _nationalityFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _nationalityController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _middleNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailAddressFocusNode.dispose();
    _birthDateFocusNode.dispose();
    _genderFocusNode.dispose();
    _nationalityFocusNode.dispose();

    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailAddressController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _canSubmit.dispose();

    super.dispose();
  }

  void _onChanged(String value) {
    final canSubmit =
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailAddressController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty &&
        _genderController.text.isNotEmpty &&
        _nationalityController.text.isNotEmpty;

    _canSubmit.value = canSubmit;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      title: l10n.kycPersonalInfoTitle,
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
            FormInput(
              focusNode: _firstNameFocusNode,
              controller: _firstNameController,
              label: l10n.profileFirstNameLabel,
              onChanged: _onChanged,
              next: (value) {
                _middleNameFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _middleNameFocusNode,
              controller: _middleNameController,
              label: l10n.profileMiddleNameLabel,
              onChanged: _onChanged,
              next: (value) {
                _lastNameFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _lastNameFocusNode,
              controller: _lastNameController,
              label: l10n.profileLastNameLabel,
              onChanged: _onChanged,
              next: (value) {
                _emailAddressFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _emailAddressFocusNode,
              controller: _emailAddressController,
              label: l10n.profileEmailAddressLabel,
              onChanged: _onChanged,
              next: (value) {
                _birthDateFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormDateInput(
              focusNode: _birthDateFocusNode,
              controller: _birthDateController,
              label: l10n.profileDateOfBirthLabel,
              onChanged: (date) {
                _onChanged(_birthDateController.text);
              },
              next: (value) {
                _genderFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: FormSelectInput(
                    focusNode: _genderFocusNode,
                    controller: _genderController,
                    label: l10n.profileGenderLabel,
                    placeholder: l10n.kycSelectPlaceholder,
                    onChanged: _onChanged,
                    next: (value) {
                      _nationalityFocusNode.requestFocus();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: FormSelectInput(
                    focusNode: _nationalityFocusNode,
                    controller: _nationalityController,
                    label: l10n.kycNationalityLabel,
                    placeholder: l10n.kycSelectPlaceholder,
                    onChanged: _onChanged,
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
