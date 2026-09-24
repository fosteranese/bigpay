import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';

/// "Verify your identity" sheet for a `6000` response (identity verification
/// required) — shown app-wide by the root listener in app.dart, whichever
/// screen's request hit it. Starting verification opens the KYC flow, which
/// returns to this screen (and runs [Kyc.onSuccess], if the screen set one)
/// once it succeeds.
void showVerifyIdentityPrompt(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  // Where KYC hands back to on success (ContactInfoKycPage pops to it) —
  // read now, while the screen that hit 6000 is still the current route.
  Kyc.route = PageRouteDefinition(path: GoRouter.of(context).state.path!);
  AppModal.showBottomModal(
    context,
    label: l10n.servicesVerifyIdentityTitle,
    padding: .all(20),
    children: [
      SizedBox(height: 10),
      Text(
        l10n.servicesVerifyIdentityMessage,
        style: context.smallDetails.copyWith(
          color: context.textPrimary,
        ),
      ),
      SizedBox(height: Spacing.xl),
      Align(
        alignment: .bottomRight,
        child: Text(
          l10n.servicesPercentComplete,
          style: context.caption,
        ),
      ),
      SizedBox(height: 5),
      Container(
        height: 8,
        alignment: .centerLeft,
        decoration: BoxDecoration(
          borderRadius: .circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter, // 180deg points from top to bottom
            end: Alignment.bottomCenter,
            stops: [
              0.0,
              0.5052,
              1.0,
            ], // Exact CSS percentage stops
            colors: [
              context.textTertiary,
              context.border,
              context.divider,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraint) {
            return Container(
              width: 0.6 * constraint.maxWidth,
              decoration: BoxDecoration(
                borderRadius: .circular(20),
                color: context.accentGreen,
              ),
            );
          },
        ),
      ),
      SizedBox(height: 30),
      FormButton(
        height: 45,
        onPressed: () {
          AppRouter.router.pop();
          AppRouter.router.push(IntroKycPage.route.path);
        },
        text: l10n.servicesStartVerification,
      ),
    ],
  );
}

/// Shows [showVerifyIdentityPrompt] whenever any request comes back `6000`,
/// whichever screen made it. Screens' own listeners never see that error
/// (see `_forScreen` in process_builder.dart), so it's handled exactly once.
class VerifyIdentityGate extends StatelessWidget {
  const VerifyIdentityGate({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  /// The navigator the prompt is shown on — its context sits under the
  /// router, which [showVerifyIdentityPrompt] reads the current route from.
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessBloc, ProcessState>(
      listenWhen: (_, state) =>
          state is ExecuteProcessError &&
          !state.isSilent &&
          !state.isCachedData &&
          state.error.code == StatusCodeConstants.verifyIdentify,
      listener: (_, state) {
        // A pending retry belongs to the request that set it only.
        if (state.event != Kyc.retryEvent) {
          Kyc.onSuccess = null;
          Kyc.retryEvent = null;
        }
        // Deferred past every other listener for this state: screens close
        // their loading dialog with MessageUtil.close, which pops whatever
        // is topmost — it would take this sheet with it.
        Future(() {
          final navContext = navigatorKey.currentContext;
          if (navContext != null && navContext.mounted) {
            showVerifyIdentityPrompt(navContext);
          }
        });
      },
      child: child,
    );
  }
}
