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
    this.validator,
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
  final String? Function(String? value)? validator;

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
              // The visual label above is a separate Text, not the
              // TextField's own InputDecoration.labelText, so it isn't
              // programmatically associated with the field for a screen
              // reader on its own — this ties them together explicitly.
              child: Semantics(
                label: widget.label ?? widget.placeholder,
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
                  validator: widget.validator,
                  onFieldSubmitted: (value) {
                    widget.next?.call(value);
                  },
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    contentPadding: widget.padding,
                    hintText: widget.placeholder,
                    hintStyle: context.caption,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: .circular(10),
                      borderSide: BorderSide(
                        color: context.border,
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: .circular(10),
                      borderSide: BorderSide(
                        color: AppColors.danger,
                        style: .solid,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: .circular(10),
                      borderSide: BorderSide(
                        color: AppColors.danger,
                        style: .solid,
                        width: 2,
                      ),
                    ),
                    errorMaxLines: 2,
                    errorStyle: context.caption.copyWith(
                      color: AppColors.danger,
                    ),
                    filled: true,
                    fillColor: context.inputBg,
                    suffixIcon: widget.suffix,
                  ),
                ),
              ),
            ),
            if (field.hasError && field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 15),
                child: Text(
                  field.errorText!,
                  style: context.caption.copyWith(
                    color: AppColors.danger,
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
        style: context.formLabels,
      ),
    );
  }
}
