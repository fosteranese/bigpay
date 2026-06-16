import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ButtonIconAlignment { left, right }

class FormButton extends StatelessWidget {
  const FormButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.labelSize,
    this.icon,
    this.buttonIconAlignment = ButtonIconAlignment.right,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: !loading ? backgroundColor : AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(height),
          ),
          fixedSize: Size(double.maxFinite, height),
        ),
        onPressed: () {
          if (loading) {
            return;
          }

          onPressed();
        },
        child: _content,
      ),
    );
  }

  Widget get _content {
    if (loading) {
      final double size = height > 30 ? 30 : 10;
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: AppColors.secondary,
        ),
      );
    }

    return icon == null && svgIcon == null ? _text : _textAndIcon;
  }

  Widget get _text {
    return Text(
      text,
      maxLines: 1,
      style: AppTypography.buttons.copyWith(
        fontSize: labelSize ?? 16,
        fontWeight: fontWeight ?? .bold,
        color: foregroundColor,
      ),
    );
  }

  Widget get _icon {
    if (svgIcon?.isNotEmpty ?? false) {
      return SvgPicture.asset(
        svgIcon!,
        colorFilter: ColorFilter.mode(
          iconColor ?? foregroundColor,
          BlendMode.srcIn,
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

  Widget get _textAndIcon {
    if (buttonIconAlignment == ButtonIconAlignment.left) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _icon,
          SizedBox(width: iconSpacerBeforeAfter ?? 10),
          _text,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _text,
        SizedBox(width: iconSpacerBeforeAfter ?? 10),
        _icon,
      ],
    );
  }
}
