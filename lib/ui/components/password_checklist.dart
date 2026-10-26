import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.password});

  final String password;

  static bool allPassed(String password) {
    return password.length >= 6 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rules = <({bool passed, String label})>[
      (passed: password.length >= 6, label: l10n.passwordRuleMinLength),
      (passed: RegExp(r'[A-Z]').hasMatch(password), label: l10n.passwordRuleUppercase),
      (passed: RegExp(r'[a-z]').hasMatch(password), label: l10n.passwordRuleLowercase),
      (passed: RegExp(r'[0-9]').hasMatch(password), label: l10n.passwordRuleNumber),
      (passed: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password), label: l10n.passwordRuleSpecialChar),
    ];

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: rules.map((rule) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                rule.passed ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: rule.passed ? AppColors.success : context.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rule.label,
                  style: context.smallDetails.copyWith(
                    color: rule.passed ? AppColors.success : context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
