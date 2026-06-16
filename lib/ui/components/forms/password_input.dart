import 'package:bigpay/ui/components/forms/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FormPasswordInput extends StatefulWidget {
  const FormPasswordInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.focusNode,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;

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
          suffix: IconButton(
            onPressed: () {
              _isPassword.value = !_isPassword.value;
            },
            icon: SvgPicture.asset(
              'assets/img/${value ? 'visible' : 'invisible'}.svg',
            ),
          ),
        );
      },
    );
  }
}
