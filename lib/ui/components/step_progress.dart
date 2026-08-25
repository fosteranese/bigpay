import 'package:flutter/material.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  final int currentStep;
  final int totalSteps;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isShortHeight;
    final isWide = context.isExpanded;

    if (isWide && labels != null) {
      return _buildVertical(context);
    }
    return _buildHorizontal(context, isCompact);
  }

  Widget _buildHorizontal(BuildContext context, bool isCompact) {
    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            return Expanded(
              child: Container(
                height: isCompact ? 3 : 4,
                margin: .symmetric(
                  horizontal: index == 0 || index == totalSteps - 1 ? 0 : 2,
                ),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? context.accentGreen
                      : context.border,
                  borderRadius: BorderRadius.only(
                    topLeft: index == 0 ? Radius.circular(2) : Radius.zero,
                    bottomLeft: index == 0 ? Radius.circular(2) : Radius.zero,
                    topRight: index == totalSteps - 1
                        ? Radius.circular(2)
                        : Radius.zero,
                    bottomRight: index == totalSteps - 1
                        ? Radius.circular(2)
                        : Radius.zero,
                  ),
                ),
              ),
            );
          }),
        ),
        if (!isCompact && labels != null) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            '${labels![currentStep]} (${currentStep + 1}/$totalSteps)',
            style: context.caption,
            textAlign: .center,
          ),
        ],
      ],
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == totalSteps - 1;
        return Row(
          crossAxisAlignment: .start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? context.accentGreen
                        : context.border,
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, size: 16, color: AppColors.white)
                      : isCurrent
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
                            )
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: isCompleted ? context.accentGreen : context.border,
                  ),
              ],
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Padding(
                padding: .only(top: 3),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      labels![index],
                      style: isCurrent
                          ? context.smallBold
                          : isCompleted
                              ? context.smallMedium
                              : context.small.copyWith(
                                  color: context.textTertiary,
                                ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Step ${index + 1} of $totalSteps',
                        style: context.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
