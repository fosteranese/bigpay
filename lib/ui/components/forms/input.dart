import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

class FormInput extends StatefulWidget {
  const FormInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.suffix,
    this.isPassword = false,
    this.focusNode,
    this.next,
    this.keyboardType,
    this.textInputAction,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final Widget? suffix;
  final bool isPassword;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  @override
  void initState() {
    super.initState();
  }

  TextInputAction? get _textInputAction {
    return widget.textInputAction ?? (widget.next != null ? .next : null);
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (field) {
        return Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const .only(bottom: 5),
                child: Text(
                  widget.label!,
                  style: AppTypography.formLabels,
                ),
              ),
            TextFormField(
              focusNode: widget.focusNode,
              obscureText: widget.isPassword,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textInputAction: _textInputAction,
              onFieldSubmitted: (value) {
                widget.next?.call(value);
              },
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: AppTypography.caption,
                enabledBorder: OutlineInputBorder(
                  borderRadius: .circular(10),
                  borderSide: BorderSide(
                    color: AppColors.tertiary,
                    style: .solid,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: .circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    style: .solid,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.offWhite,
                suffixIcon: widget.suffix,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
