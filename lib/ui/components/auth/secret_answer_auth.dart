import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class SecretAnswerAuthenticator extends StatefulWidget {
  const SecretAnswerAuthenticator({
    super.key,
    required this.onSuccess,
    required this.end,
  });

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/secret-answer-auth',
  );
  final void Function(String) onSuccess;
  final void Function() end;

  @override
  State<SecretAnswerAuthenticator> createState() =>
      _SecretAnswerAuthenticatorState();
}

class _SecretAnswerAuthenticatorState extends State<SecretAnswerAuthenticator> {
  final _controller = TextEditingController();
  final _hasAnswer = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => _hasAnswer.value = _controller.text.trim().isNotEmpty,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _hasAnswer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      subtitleWidget: Text(
        l10n.authSecretAnswerTitle,
        textAlign: .center,
        style: context.display1.copyWith(
          color: context.textPrimary,
        ),
      ),
      bottomNav: Column(
        mainAxisSize: .min,
        children: [
          ValueListenableBuilder(
            valueListenable: _hasAnswer,
            builder: (context, value, child) {
              return FormButton(
                onPressed: () {
                  widget.end();
                  widget.onSuccess(_controller.text);
                },
                enabled: value,
                text: l10n.commonSubmit,
              );
            },
          ),
          TextButton(
            onPressed: widget.end,
            child: Text(l10n.commonCancel, style: context.formLabels),
          ),
        ],
      ),
      child: Center(
        child: Form(
          child: FormPasswordInput(
            label: l10n.authAnswerToQuestionLabel,
            controller: _controller,
          ),
        ),
      ),
    );
  }
}
