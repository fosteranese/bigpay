import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';

class FormPinUnifiedInput extends StatefulWidget {
  const FormPinUnifiedInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.focusNode,
    this.next,
    this.onChanged,
    this.length = 4,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final void Function(String value)? onChanged;
  final int length;

  @override
  State<FormPinUnifiedInput> createState() => _FormPinUnifiedInputState();
}

class _FormPinUnifiedInputState extends State<FormPinUnifiedInput> {
  final _isPassword = ValueNotifier(true);

  @override
  void dispose() {
    _isPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isPassword,
      builder: (context, value, child) {
        return FormInput(
          label: widget.label,
          placeholder: widget.placeholder,
          controller: widget.controller,
          isPassword: value,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          maxLength: widget.length,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          next: widget.next,
          onChanged: widget.onChanged,
          suffix: IconButton(
            onPressed: () {
              _isPassword.value = !_isPassword.value;
            },
            icon: SvgPicture.asset(
              value ? SvgImages.visible : SvgImages.invisible,
            ),
          ),
        );
      },
    );
  }
}
