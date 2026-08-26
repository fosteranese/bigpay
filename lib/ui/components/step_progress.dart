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

  /// Only ever rendered inside the auth brand panel, which is a fixed dark
  /// gradient in both themes — so this variant uses [AppColors.brightGreen]
  /// and white directly instead of the theme-adaptive getters (which would
  /// resolve to the light theme's dark green and disappear on the navy).
  Widget _buildVertical(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == totalSteps - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
          child: _StepCard(
            step: index + 1,
            label: labels![index],
            isCompleted: isCompleted,
            isCurrent: isCurrent,
          ),
        );
      }),
    );
  }
}

/// One step rendered as a contained row card — completed/current states get
/// a real surface and border so the list reads as designed UI rather than a
/// bare circle-and-line stepper dropped onto the gradient.
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
  });

  final int step;
  final String label;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.white.withValues(alpha: 0.12)
            : isCompleted
                ? AppColors.white.withValues(alpha: 0.06)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? AppColors.brightGreen.withValues(alpha: 0.7)
              : AppColors.white.withValues(
                  alpha: isCompleted ? 0.14 : 0.09,
                ),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.brightGreen.withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _circle(context),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: context.p1.copyWith(
                color: isCurrent
                    ? AppColors.white
                    : isCompleted
                        ? AppColors.white.withValues(alpha: 0.85)
                        : AppColors.white.withValues(alpha: 0.5),
                fontWeight: isCurrent
                    ? FontWeight.w700
                    : isCompleted
                        ? FontWeight.w600
                        : FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          if (isCurrent)
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brightGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _circle(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.brightGreen
            : isCurrent
                ? AppColors.white
                : Colors.transparent,
        border: Border.all(
          color: isCompleted || isCurrent
              ? (isCompleted ? AppColors.brightGreen : AppColors.white)
              : AppColors.white.withValues(alpha: 0.3),
          width: isCompleted || isCurrent ? 0 : 1.5,
        ),
      ),
      child: isCompleted
          ? Icon(Icons.check_rounded, size: 17, color: AppColors.white)
          : Center(
              child: Text(
                '$step',
                style: context.header4.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.white.withValues(alpha: 0.55),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
    );
  }
}
