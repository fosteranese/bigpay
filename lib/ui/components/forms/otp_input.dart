import 'dart:async';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormOtpInput extends StatefulWidget {
  const FormOtpInput({
    super.key,
    this.count = 6,
    this.obscureText = false,
    this.enableAutofill = true,
    this.resendDuration = 90,
    this.autoFocus = true,
    this.error,
    this.onChanged,
    this.onCompleted,
    this.onResend,
  });

  final int count;
  final bool obscureText;
  final bool enableAutofill;
  final int resendDuration;
  final bool autoFocus;
  final String? error;
  final void Function(String value)? onChanged;
  final void Function(String value)? onCompleted;
  final VoidCallback? onResend;

  @override
  State<FormOtpInput> createState() => FormOtpInputState();
}

class FormOtpInputState extends State<FormOtpInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late Timer _timer;
  late int _remainingSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _remainingSeconds = widget.resendDuration;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.autoFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  // A single backing field for the whole code, with the boxes below purely
  // decorative. Deleting a character from a non-empty field is completely
  // standard text editing that every platform delivers reliably; the
  // previous one-TextField-per-digit design instead depended on each
  // digit's own field reporting backspace-while-already-empty (to clear the
  // *previous* box and move focus back), which real iOS devices — unlike
  // the Simulator — frequently never report at all, since there is no text
  // change for the system to notify Flutter about. Routing everything
  // through one field sidesteps that platform gap entirely.
  void _onChanged() {
    final digits = _controller.text;
    widget.onChanged?.call(digits);
    if (digits.length == widget.count) {
      _focusNode.unfocus();
      widget.onCompleted?.call(digits);
    }
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = widget.resendDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        if (mounted) {
          setState(() => _canResend = true);
        }
        timer.cancel();
      } else {
        if (mounted) {
          setState(() => _remainingSeconds--);
        }
      }
    });
  }

  void _onResendPressed() {
    clear();
    widget.onResend?.call();
    _startTimer();
  }

  void clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _borderColor(int index) {
    final activeIndex = _controller.text.length.clamp(0, widget.count - 1);
    if (_focusNode.hasFocus && index == activeIndex) return AppColors.tint;
    if (index < _controller.text.length) return AppColors.primary;
    return context.border;
  }

  Widget _box(int index) {
    final text = _controller.text;
    final filled = index < text.length;
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _borderColor(index),
            width: _focusNode.hasFocus &&
                    index == text.length.clamp(0, widget.count - 1)
                ? 2
                : 1,
          ),
        ),
      ),
      child: Text(
        filled ? (widget.obscureText ? '•' : text[index]) : '',
        style: context.header1,
      ),
    );
  }

  Widget _otpFields() {
    final boxes = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.count, _box),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 0,
            width: 0,
            child: AutofillGroup(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                autofillHints: widget.enableAutofill
                    ? const [AutofillHints.oneTimeCode]
                    : null,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.count),
                ],
              ),
            ),
          ),
        ),
        boxes,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _otpFields(),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              widget.error!,
              style: context.smallDetails.copyWith(
                color: AppColors.danger,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        if (widget.onResend != null && _canResend)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onResendPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 15,
              ),
              child: Text(
                AppLocalizations.of(context)!.otpResendCode,
                style: context.smallDetailsBold.copyWith(
                  color: context.textPrimary,
                  decoration: .underline,
                ),
              ),
            ),
          )
        else if (widget.onResend != null)
          Row(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              SvgPicture.asset(SvgImages.timer),
              SizedBox(width: 5),
              Text(
                AppLocalizations.of(context)!.otpResendCodeIn(
                  Duration(
                    seconds: _remainingSeconds,
                  ).toString().split('.').first.substring(2),
                ),
                style: context.smallDetails,
              ),
            ],
          ),
      ],
    );
  }
}
