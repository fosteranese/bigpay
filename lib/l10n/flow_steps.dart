import 'package:bigpay/l10n/app_localizations.dart';

/// Human, welcoming step labels for the flow progress indicators, grouped per
/// flow so every page in a given flow stays in sync from a single source.
extension FlowStepLabels on AppLocalizations {
  List<String> get signupSteps => [
        stepSignupPhone,
        stepSignupCode,
        stepSignupPassword,
        stepSignupSecurity,
        stepSignupPin,
      ];

  List<String> get forgotPwdSteps => [
        stepForgotVerify,
        stepForgotCode,
        stepForgotPassword,
      ];

  List<String> get kycSteps => [
        stepKycId,
        stepKycSelfie,
        stepKycContact,
      ];

  List<String> get signInSteps => [
        stepSigninDetails,
        stepSigninSecurity,
        stepSigninCode,
      ];
}
