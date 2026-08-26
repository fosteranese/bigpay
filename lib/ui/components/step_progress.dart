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

  // Just the segmented bar, no "(current/total)" caption underneath — this
  // renders in MainLayout's header right above the page's own title (e.g.
  // "Enter OTP"), which already names the current step, so a text label
  // repeating that here read as cluttered rather than informative. The
  // vertical/labeled variant below is a different context (the auth brand
  // panel, with no adjacent title of its own) and keeps its labels.
  Widget _buildHorizontal(BuildContext context, bool isCompact) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        return Expanded(
          child: Container(
            height: isCompact ? 4 : 5,
            margin: .symmetric(
              horizontal: index == 0 || index == totalSteps - 1 ? 0 : 2,
            ),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? context.accentGreen
                  : context.textSecondary.withValues(alpha: 0.55),
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

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: .stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? context.accentGreen
                            : isCurrent
                                ? AppColors.white
                                : Colors.transparent,
                        border: isCompleted || isCurrent
                            ? Border.all(
                                color: context.accentGreen,
                                width: 2,
                              )
                            : Border.all(
                                color: context.textSecondary.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: context.accentGreen.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, size: 18, color: AppColors.white)
                          : isCurrent
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.accentGreen,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: context.caption.copyWith(
                                      color: context.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: const .symmetric(vertical: 4),
                          color: isCompleted
                              ? context.accentGreen
                              : context.textSecondary.withValues(alpha: 0.25),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    bottom: isLast ? 0 : Spacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        labels![index],
                        style: isCurrent
                            ? context.smallBold.copyWith(
                                color: context.accentGreen,
                              )
                            : isCompleted
                                ? context.smallMedium
                                : context.small.copyWith(
                                    color: context.textSecondary,
                                  ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Step ${index + 1} of $totalSteps',
                          style: context.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
