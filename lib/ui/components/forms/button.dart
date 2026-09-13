import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

enum ButtonIconAlignment { left, right }

class FormButton extends StatelessWidget {
  const FormButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.labelSize,
    this.icon,
    this.buttonIconAlignment = .right,
    this.backgroundColor = AppColors.tint,
    this.foregroundColor = Colors.white,
    this.iconColor,
    this.height = 56,
    this.loading = false,
    this.iconSize,
    this.iconSpacerBeforeAfter,
    this.svgIcon,
    this.fontWeight,
    this.borderRadius,
    this.enabled = true,
    this.padding = const .symmetric(
      horizontal: 8,
      vertical: 8,
    ),
  });

  final void Function() onPressed;
  final String text;
  final double? labelSize;
  final IconData? icon;
  final ButtonIconAlignment buttonIconAlignment;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? iconSize;
  final Color? iconColor;
  final double? iconSpacerBeforeAfter;
  final double height;
  final bool loading;
  final String? svgIcon;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: loading || !enabled
              ? context.avatarBg
              : backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? .circular(height),
          ),
          minimumSize: Size(double.maxFinite, height),
        ),
        // null (rather than a no-op callback) so Material — and screen
        // readers — actually treat the button as disabled while loading.
        onPressed: (loading || !enabled) ? null : onPressed,
        child: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (loading) {
      final double size = height > 30 ? 30 : 10;
      return Semantics(
        label: '$text, loading',
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: foregroundColor,
          ),
        ),
      );
    }

    return icon == null && svgIcon == null ? _text(context) : _textAndIcon(context);
  }

  Widget _text(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      style: context.buttons.copyWith(
        fontSize: labelSize ?? 16,
        fontWeight: fontWeight ?? .bold,
        color: enabled ? foregroundColor : AppColors.flora,
      ),
    );
  }

  Widget get _icon {
    if (svgIcon?.isNotEmpty ?? false) {
      return SvgPicture.asset(
        svgIcon!,
        colorFilter: .mode(
          iconColor ?? foregroundColor,
          .srcIn,
        ),
        width: iconSize ?? labelSize ?? 30,
      );
    }

    return Icon(
      icon,
      color: iconColor ?? foregroundColor,
      size: iconSize ?? labelSize ?? 30,
    );
  }

  Widget _textAndIcon(BuildContext context) {
    if (buttonIconAlignment == .left) {
      return Row(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          _icon,
          SizedBox(width: iconSpacerBeforeAfter ?? 10),
          _text(context),
        ],
      );
    }

    return Row(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        _text(context),
        SizedBox(width: iconSpacerBeforeAfter ?? 10),
        _icon,
      ],
    );
  }
}
