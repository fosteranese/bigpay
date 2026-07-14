import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';

class ContactInfoKycPage extends StatefulWidget {
  const ContactInfoKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/contact',
  );

  @override
  State<ContactInfoKycPage> createState() => _ContactInfoKycPageState();
}

class _ContactInfoKycPageState extends State<ContactInfoKycPage> {
  final _emailAddressFocusNode = FocusNode();
  final _streetAddressFocusNode = FocusNode();
  final _digitalAddressFocusNode = FocusNode();

  final _emailAddressController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _digitalAddressController = TextEditingController();

  final _canSubmit = ValueNotifier(false);

  @override
  void dispose() {
    _emailAddressFocusNode.dispose();
    _streetAddressFocusNode.dispose();
    _digitalAddressFocusNode.dispose();

    _emailAddressController.dispose();
    _streetAddressController.dispose();
    _digitalAddressController.dispose();

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
    return MainLayout(
      title: 'Personal Information',
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
              focusNode: _emailAddressFocusNode,
              controller: _emailAddressController,
              label: 'Email Address *',
              onChanged: _onChanged,
              next: (value) {
                _streetAddressFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _streetAddressFocusNode,
              controller: _streetAddressController,
              label: 'Street Address *',
              onChanged: _onChanged,
              next: (value) {
                _digitalAddressFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 15),
            FormInput(
              focusNode: _digitalAddressFocusNode,
              controller: _digitalAddressController,
              label: 'Digital Address',
              onChanged: _onChanged,
              next: (value) {
                FocusScope.of(context).unfocus();
              },
              textInputAction: .done,
            ),
          ],
        ),
      ),
    );
  }
}
