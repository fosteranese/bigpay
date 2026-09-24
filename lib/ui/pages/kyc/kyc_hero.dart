import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// The shared "visual, title, subtitle" block every KYC hero screen opens
/// with (selfie info, photo review, camera-permission denied, intro), so the
/// flow reads as one set of screens: same type ramp, rhythm and line length.
class KycHero extends StatelessWidget {
  const KycHero({
    super.key,
    this.visual,
    required this.title,
    required this.subtitle,
  });

  final Widget? visual;
  final String title;
  final String subtitle;

  /// Readable measure for centered copy; wider lines read as a paragraph.
  static const double textMaxWidth = 300;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        if (visual != null) ...[
          visual!,
          const SizedBox(height: Spacing.xl),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: textMaxWidth),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(
                title,
                textAlign: .center,
                style: context.display2,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                subtitle,
                textAlign: .center,
                style: context.smallDetails,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
