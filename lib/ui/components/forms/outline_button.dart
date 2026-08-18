import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormOutlineButton extends StatelessWidget {
  const FormOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.labelSize,
    this.icon,
    this.buttonIconAlignment = .right,
    this.backgroundColor = AppColors.tint,
    this.foregroundColor,
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
  final Color? foregroundColor;
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
    final effectiveForeground = foregroundColor ?? context.textPrimary;
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: loading || !enabled
              ? context.cardBg
              : null,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? .circular(height),
            side: BorderSide(
              color: enabled ? context.border : AppColors.flora,
              width: 1,
            ),
          ),
          fixedSize: Size(double.maxFinite, height),
        ),
        onPressed: onPressed,
        child: _content(context, effectiveForeground),
      ),
    );
  }

  Widget _content(BuildContext context, Color effectiveForeground) {
    if (loading) {
      final double size = height > 30 ? 30 : 10;
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return icon == null && svgIcon == null
        ? _text(context, effectiveForeground)
        : _textAndIcon(context, effectiveForeground);
  }

  Widget _text(BuildContext context, Color effectiveForeground) {
    return Text(
      text,
      maxLines: 1,
      style: AppTypography.buttons.copyWith(
        fontSize: labelSize ?? 16,
        fontWeight: fontWeight ?? .bold,
        color: enabled ? effectiveForeground : AppColors.flora,
      ),
    );
  }

  Widget _icon(Color effectiveForeground) {
    if (svgIcon?.isNotEmpty ?? false) {
      return SvgPicture.asset(
        svgIcon!,
        colorFilter: .mode(
          iconColor ?? effectiveForeground,
          .srcIn,
        ),
        width: iconSize ?? labelSize ?? 30,
      );
    }

    return Icon(
      icon,
      color: iconColor ?? effectiveForeground,
      size: iconSize ?? labelSize ?? 30,
    );
  }

  Widget _textAndIcon(BuildContext context, Color effectiveForeground) {
    if (buttonIconAlignment == .left) {
      return Row(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          _icon(effectiveForeground),
          SizedBox(width: iconSpacerBeforeAfter ?? 10),
          _text(context, effectiveForeground),
        ],
      );
    }

    return Row(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        _text(context, effectiveForeground),
        SizedBox(width: iconSpacerBeforeAfter ?? 10),
        _icon(effectiveForeground),
      ],
    );
  }
}
