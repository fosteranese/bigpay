import 'package:bigpay/ui/components/forms/otp_input.dart';
import 'package:flutter/material.dart';

class FormPinInput extends StatelessWidget {
  const FormPinInput({
    super.key,
    this.formKey,
    this.count = 4,
    this.error,
    this.onChanged,
    this.onCompleted,
  });

  final GlobalKey<FormOtpInputState>? formKey;
  final int count;
  final String? error;
  final void Function(String value)? onChanged;
  final void Function(String value)? onCompleted;

  @override
  Widget build(BuildContext context) {
    return FormOtpInput(
      key: formKey,
      count: count,
      obscureText: true,
      enableAutofill: false,
      error: error,
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
