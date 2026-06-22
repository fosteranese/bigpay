import 'dart:async';

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
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  TextEditingController? _autofillController;
  late Timer _timer;
  late int _remainingSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.count, (i) {
      final c = TextEditingController();
      c.addListener(() {
        if (mounted) setState(() => _alignCursor(i));
      });
      return c;
    });
    _focusNodes = List.generate(widget.count, (_) {
      final node = FocusNode();
      node.addListener(() {
        if (mounted) setState(_onFocusChange);
      });
      return node;
    });
    if (widget.enableAutofill) {
      _autofillController = TextEditingController()
        ..addListener(_onAutoFillDetected);
    }
    _remainingSeconds = widget.resendDuration;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.autoFocus) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _onAutoFillDetected() {
    final c = _autofillController;
    if (c == null) return;
    final text = c.text;
    if (text.isNotEmpty) {
      _handlePaste(0, text);
      c.clear();
    }
  }

  void _alignCursor(int index) {
    final text = _controllers[index].text;
    if (text.isNotEmpty && mounted) {
      _controllers[index].selection = TextSelection.collapsed(
        offset: text.length,
      );
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

  void _onFocusChange() {
    for (var i = 0; i < widget.count; i++) {
      if (_focusNodes[i].hasFocus) {
        _alignCursor(i);
        _ensureSequential(i);
        break;
      }
    }
  }

  void _ensureSequential(int tappedIndex) {
    for (var j = 0; j < widget.count; j++) {
      if (_controllers[j].text.isEmpty) {
        _focusNodes[j].requestFocus();
        return;
      }
    }
    _focusNodes[widget.count - 1].requestFocus();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event, int index) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _emitOtp();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(index, value);
      return;
    }

    if (value.isNotEmpty && index < widget.count - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == widget.count - 1) {
      _focusNodes[index].unfocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _emitOtp();
  }

  void _handlePaste(int startIndex, String pasted) {
    final digits = pasted.replaceAll(RegExp(r'[^0-9]'), '');
    for (var i = 0; i < digits.length && startIndex + i < widget.count; i++) {
      _controllers[startIndex + i].text = digits[i];
    }
    final nextIndex = (startIndex + digits.length).clamp(0, widget.count - 1);
    if (nextIndex < widget.count - 1) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes[widget.count - 1].unfocus();
    }
    _emitOtp();
  }

  void _emitOtp() {
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);
    if (otp.length == widget.count) {
      widget.onCompleted?.call(otp);
    }
  }

  Widget _otpFields() {
    final fields = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.count, (index) {
        return Focus(
          onKeyEvent: (node, event) => _onKeyEvent(node, event, index),
          child: SizedBox(
            width: 48,
            height: 56,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              obscureText: widget.obscureText,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: AppTypography.header1,
              decoration: InputDecoration(
                counterText: '',
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: _borderColor(index),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.tint,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onDigitChanged(index, value),
            ),
          ),
        );
      }),
    );

    if (_autofillController == null) return fields;

    return AutofillGroup(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 0,
              width: 0,
              child: TextField(
                controller: _autofillController,
                autofillHints: const [AutofillHints.oneTimeCode],
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          fields,
        ],
      ),
    );
  }

  Color _borderColor(int index) {
    if (_focusNodes[index].hasFocus) return AppColors.tint;
    if (_controllers[index].text.isNotEmpty) return AppColors.primary;
    return AppColors.tertiary;
  }

  void _onResendPressed() {
    clear();
    widget.onResend?.call();
    _startTimer();
  }

  void clear() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _emitOtp();
  }

  @override
  void dispose() {
    _timer.cancel();
    _autofillController
      ?..removeListener(_onAutoFillDetected)
      ..dispose();
    for (var i = 0; i < widget.count; i++) {
      _focusNodes[i].removeListener(_onFocusChange);
      _focusNodes[i].dispose();
      _controllers[i].dispose();
    }
    super.dispose();
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
              style: AppTypography.smallDetails.copyWith(
                color: AppColors.danger,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        if (widget.onResend != null && _canResend)
          GestureDetector(
            onTap: _onResendPressed,
            child: Text(
              'Resend Code',
              style: AppTypography.smallDetailsBold.copyWith(
                color: AppColors.black,
                decoration: .underline,
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
                'Resend code in ${Duration(seconds: _remainingSeconds).toString().split('.').first.substring(2)}',
                style: AppTypography.smallDetails,
              ),
            ],
          ),
      ],
    );
  }
}
