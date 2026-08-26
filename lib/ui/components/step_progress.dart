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
                width: 44,
                child: Column(
                  children: [
                    _StepCircle(
                      step: index + 1,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 2,
                            margin: const .symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? context.accentGreen
                                  : AppColors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xl),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : Spacing.xxl,
                  ),
                  child: Center(
                    heightFactor: 1,
                    child: Text(
                      labels![index],
                      style: context.p1.copyWith(
                        color: isCurrent
                            ? AppColors.white
                            : isCompleted
                                ? AppColors.white.withValues(alpha: 0.9)
                                : AppColors.white.withValues(alpha: 0.55),
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : isCompleted
                                ? FontWeight.w600
                                : FontWeight.w400,
                      ),
                    ),
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

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
  });

  final int step;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? context.accentGreen
            : isCurrent
                ? AppColors.white
                : Colors.transparent,
        border: Border.all(
          color: isCompleted || isCurrent
              ? context.accentGreen
              : AppColors.white.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: context.accentGreen.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
      ),
      child: isCompleted
          ? Icon(Icons.check_rounded, size: 22, color: AppColors.white)
          : Center(
              child: Text(
                '$step',
                style: context.p1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? context.accentGreen
                      : AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
    );
  }
}
