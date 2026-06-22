import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'forms.dart';

class FormTextAreaInput extends StatelessWidget {
  const FormTextAreaInput({
    super.key,
    required this.controller,
    this.label,
    this.readOnly = false,
    this.placeholder,
    this.suffix,
    this.isPassword = false,
    this.focusNode,
    this.next,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 5,
  });

  final TextEditingController controller;
  final bool readOnly;
  final String? label;
  final String? placeholder;
  final Widget? suffix;
  final bool isPassword;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String value)? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return FormInput(
      label: label,
      placeholder: placeholder,
      controller: controller,
      height: 140,
      maxLines: maxLines,
    );
  }
}
