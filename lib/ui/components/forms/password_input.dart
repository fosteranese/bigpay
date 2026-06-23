import 'package:bigpay/ui/components/forms/input.dart';
import 'package:flutter/material.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter_svg/svg.dart';

class FormPasswordInput extends StatefulWidget {
  const FormPasswordInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.focusNode,
    this.next,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final void Function(String value)? onChanged;

  @override
  State<FormPasswordInput> createState() => _FormPasswordInputState();
}

class _FormPasswordInputState extends State<FormPasswordInput> {
  final _isPassword = ValueNotifier(true);

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
          keyboardType: value ? null : .visiblePassword,
          next: widget.next,
          onChanged: widget.onChanged,
          maxLines: 1,
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
