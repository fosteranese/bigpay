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
    this.focusNode,
    this.next,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 5,
    this.validator,
  });

  final TextEditingController controller;
  final bool readOnly;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String value)? onChanged;
  final int maxLines;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 140),
      child: FormInput(
        label: label,
        placeholder: placeholder,
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        next: next,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}
