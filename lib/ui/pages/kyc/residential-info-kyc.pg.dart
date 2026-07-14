import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';

class ResidentialInfoKycPage extends StatefulWidget {
  const ResidentialInfoKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/residential',
  );

  @override
  State<ResidentialInfoKycPage> createState() => _ResidentialInfoKycPageState();
}

class _ResidentialInfoKycPageState extends State<ResidentialInfoKycPage> {
  final _regionFocusNode = FocusNode();
  final _districtFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _digitalAddressFocusNode = FocusNode();
  final _countryFocusNode = FocusNode();
  final _nationalityFocusNode = FocusNode();

  final _regionController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _digitalAddressController = TextEditingController();
  final _countryController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _regionFocusNode.dispose();
    _districtFocusNode.dispose();
    _cityFocusNode.dispose();
    _digitalAddressFocusNode.dispose();
    _countryFocusNode.dispose();
    _nationalityFocusNode.dispose();

    _regionController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _digitalAddressController.dispose();
    _countryController.dispose();

    super.dispose();
  }

  void _onChanged(String value) {
    final canSubmit =
        _regionController.text.isNotEmpty &&
        _districtController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _digitalAddressController.text.isNotEmpty &&
        _countryController.text.isNotEmpty;

    _canSubmit.value = canSubmit;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Residential Address',
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
            FormInput(
              focusNode: _regionFocusNode,
              controller: _regionController,
              label: 'State / Region *',
              onChanged: _onChanged,
              next: (value) {
                _districtFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _districtFocusNode,
              controller: _districtController,
              label: 'District',
              onChanged: _onChanged,
              next: (value) {
                _cityFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _cityFocusNode,
              controller: _cityController,
              label: 'Town / City *',
              onChanged: _onChanged,
              next: (value) {
                _digitalAddressFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _digitalAddressFocusNode,
              controller: _digitalAddressController,
              label: 'Digital Address *',
              onChanged: _onChanged,
              next: (value) {
                _countryFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormSelectInput(
              focusNode: _countryFocusNode,
              controller: _countryController,
              label: 'Country *',
              placeholder: 'Select ...',
              onChanged: _onChanged,
              next: (value) {
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
