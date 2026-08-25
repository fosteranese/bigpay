import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.svgAsset,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : assert((svgAsset == null) != (icon == null));

  final String? svgAsset;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: .min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 56,
                color: context.textSecondary,
              )
            else
              SvgPicture.asset(svgAsset!),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              textAlign: .center,
              style: context.p1Medium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                subtitle!,
                textAlign: .center,
                style: context.smallDetails,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Spacing.xl),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
