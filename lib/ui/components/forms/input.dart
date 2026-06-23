import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormInput extends StatefulWidget {
  const FormInput({
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
    this.height = 48,
    this.maxLines,
    this.padding = const .symmetric(horizontal: 15),
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
  final double height;
  final int? maxLines;
  final EdgeInsetsGeometry padding;

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
              FormLabel(
                label: widget.label!,
              ),
            SizedBox(
              height: widget.height,
              child: TextFormField(
                readOnly: widget.readOnly,
                focusNode: widget.focusNode,
                obscureText: widget.isPassword,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                textInputAction: _textInputAction,
                maxLength: widget.maxLength,
                maxLines: widget.maxLines,
                inputFormatters: widget.inputFormatters,
                onFieldSubmitted: (value) {
                  widget.next?.call(value);
                },
                onChanged: (value) {
                  widget.onChanged?.call(value);
                },
                decoration: InputDecoration(
                  contentPadding: widget.padding,
                  hintText: widget.placeholder,
                  hintStyle: AppTypography.caption,
                  counterText: '',
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

class FormLabel extends StatelessWidget {
  const FormLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(bottom: 5),
      child: Text(
        label,
        style: AppTypography.formLabels,
      ),
    );
  }
}
