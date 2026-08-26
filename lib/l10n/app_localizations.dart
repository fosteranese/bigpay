import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pcm.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pcm'),
  ];

  /// Label for the language switcher on the account/more page
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Generic continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic confirm/dismiss button
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get commonOk;

  /// Generic login confirm button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get commonLogin;

  /// Button to change the entered phone number
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// Placeholder for a dropdown/select input
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get commonSelectPlaceholder;

  /// Label for a phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get commonPhoneNumberLabel;

  /// Label for a password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPasswordLabel;

  /// Placeholder for a password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPasswordPlaceholder;

  /// Label for a confirm-password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get commonConfirmPasswordLabel;

  /// Link/button to switch to biometric sign-in
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get commonBiometricLogin;

  /// Link to the forgot-password flow
  ///
  /// In en, this message translates to:
  /// **'Forgot Password ?'**
  String get commonForgotPassword;

  /// Sign up page title
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUpTitle;

  /// Prompt before the sign-in link on the sign-up page
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// Link text taking the user to sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// Prefix of the terms-acceptance sentence on sign-up
  ///
  /// In en, this message translates to:
  /// **'By clicking on continue, you accept our '**
  String get authTermsPrefix;

  /// Terms of Use link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get authTermsOfUse;

  /// Conjunction between Terms of Use and Privacy Policy links
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authAnd;

  /// Privacy Policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// OTP entry page heading
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get authEnterOtp;

  /// Create-password page title
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get authCreatePasswordTitle;

  /// Button to save the new password
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get authSavePassword;

  /// Password format hint shown under the password fields
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters and include letters, numbers, and special characters (e.g. !\$@%).'**
  String get authPasswordRequirements;

  /// Password checklist rule: minimum length
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordRuleMinLength;

  /// Password checklist rule: uppercase letter required
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get passwordRuleUppercase;

  /// Password checklist rule: lowercase letter required
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter'**
  String get passwordRuleLowercase;

  /// Password checklist rule: number required
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get passwordRuleNumber;

  /// Password checklist rule: special character required
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get passwordRuleSpecialChar;

  /// Error shown when confirm password does not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// Set-PIN page title
  ///
  /// In en, this message translates to:
  /// **'Set Security PIN'**
  String get authSetSecurityPinTitle;

  /// Set-PIN page subtitle
  ///
  /// In en, this message translates to:
  /// **'Set a 4-digit code to authorize payments and keep your wallet secure.'**
  String get authSetPinSubtitle;

  /// Success dialog title after completing sign-up
  ///
  /// In en, this message translates to:
  /// **'Welcome aboard!'**
  String get authWelcomeAboardTitle;

  /// Button on the welcome-aboard success dialog
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get authGetStarted;

  /// Label for the PIN input
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit PIN'**
  String get authEnterPin;

  /// Label for the confirm-PIN input
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get authConfirmPin;

  /// Create-secure-phrase page title
  ///
  /// In en, this message translates to:
  /// **'Create a secure phrase'**
  String get authCreateSecurePhraseTitle;

  /// Subtitle shown on secure-phrase creation and entry pages
  ///
  /// In en, this message translates to:
  /// **'Customize your private Q&A for faster verification and safer digital payments.'**
  String get authSecurePhraseSubtitle;

  /// Label for the secure-phrase question dropdown
  ///
  /// In en, this message translates to:
  /// **'Choose a Question'**
  String get authChooseQuestionLabel;

  /// Label for the secure-phrase answer field
  ///
  /// In en, this message translates to:
  /// **'Answer to the Question'**
  String get authAnswerToQuestionLabel;

  /// Sign-in page title and button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// Prompt before the sign-up link on the sign-in page
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authDontHaveAccount;

  /// Link text taking the user to sign up
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpLink;

  /// Prefix before the user's name on the returning-user sign-in page
  ///
  /// In en, this message translates to:
  /// **'Welcome back, '**
  String get authWelcomeBackPrefix;

  /// Suffix after the user's name on the returning-user sign-in page
  ///
  /// In en, this message translates to:
  /// **'. \nEnter your password to continue.'**
  String get authEnterPasswordContinueSuffix;

  /// Dialog title shown when biometric login has no saved password to replay
  ///
  /// In en, this message translates to:
  /// **'Password Required'**
  String get authPasswordRequiredTitle;

  /// Dialog message shown when biometric login has no saved password to replay
  ///
  /// In en, this message translates to:
  /// **'Login with your password first to enjoy login with biometrics.'**
  String get authPasswordRequiredMessage;

  /// Validation error when the password field is left empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequiredError;

  /// Validation error when phone field is empty
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// Validation error when phone number format is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Ghana phone number (e.g. 0241234567)'**
  String get validationPhoneInvalid;

  /// Validation error when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// Validation error when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// Validation error when PIN field is empty
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get validationPinRequired;

  /// Validation error when confirm PIN does not match
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get validationPinMismatch;

  /// Validation error when security answer field is empty
  ///
  /// In en, this message translates to:
  /// **'Security answer is required'**
  String get validationAnswerRequired;

  /// Generic validation error for required fields
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationFieldRequired;

  /// Link to sign out and start a new-device sign-in as someone else
  ///
  /// In en, this message translates to:
  /// **'Not you? Use a different account'**
  String get authUseDifferentAccount;

  /// Greeting above the user's name on the existing-device sign-in page
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// Fallback greeting when the user's name is unavailable
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// Placeholder for the password field on the existing-device sign-in page
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authEnterPasswordPlaceholder;

  /// Secure-phrase entry page title (during login)
  ///
  /// In en, this message translates to:
  /// **'Enter your secure phrase'**
  String get authEnterSecurePhraseTitle;

  /// Button to trigger biometric unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get authUnlockWithBiometrics;

  /// Link to fall back to password sign-in
  ///
  /// In en, this message translates to:
  /// **'Login with Password'**
  String get authLoginWithPassword;

  /// Tooltip on the biometric icon button
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get authUnlockWithBiometricsTooltip;

  /// Forgot-password page title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPasswordTitle;

  /// Label for the secure-phrase answer field on forgot-password
  ///
  /// In en, this message translates to:
  /// **'Answer to Secure Phrase'**
  String get authAnswerToSecurePhraseLabel;

  /// Link to the forgot-secure-phrase flow
  ///
  /// In en, this message translates to:
  /// **'Forgot Secret Answer?'**
  String get authForgotSecretAnswer;

  /// Success dialog title after resetting the password
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get authSuccessfulTitle;

  /// Success dialog message after resetting the password
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. You can use your new password to log in now'**
  String get authPasswordResetSuccessMessage;

  /// Forgot-secure-phrase page title
  ///
  /// In en, this message translates to:
  /// **'Forgot Secure Phrase'**
  String get authForgotSecurePhraseTitle;

  /// Label for the email address field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddressLabel;

  /// Dialog title when a requested service form has no fields
  ///
  /// In en, this message translates to:
  /// **'Service Unavailable'**
  String get commonServiceUnavailableTitle;

  /// Dialog message when a requested service form has no fields
  ///
  /// In en, this message translates to:
  /// **'This service is currently not available'**
  String get commonServiceUnavailableMessage;

  /// Read-only first name field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get profileFirstNameLabel;

  /// Read-only middle name field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get profileMiddleNameLabel;

  /// Read-only last name field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'Last Name *'**
  String get profileLastNameLabel;

  /// Read-only email field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get profileEmailAddressLabel;

  /// Read-only date of birth field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get profileDateOfBirthLabel;

  /// Read-only gender field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'Gender *'**
  String get profileGenderLabel;

  /// Read-only nationality field label on the profile page
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get profileNationalityLabel;

  /// Security settings page title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// Dialog title when the device has no biometrics enrolled
  ///
  /// In en, this message translates to:
  /// **'Biometrics Unavailable'**
  String get securityBiometricsUnavailableTitle;

  /// Dialog message when the device has no biometrics enrolled
  ///
  /// In en, this message translates to:
  /// **'Set up Face ID or a fingerprint on your device first.'**
  String get securityBiometricsUnavailableMessage;

  /// System biometric prompt reason when enabling a biometric toggle
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometric access'**
  String get securityConfirmBiometricAccess;

  /// PIN prompt heading when confirming a biometric setting change
  ///
  /// In en, this message translates to:
  /// **'Enter Security PIN'**
  String get securityEnterPinTooltip;

  /// PIN prompt description when confirming a biometric setting change
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN to update biometric settings.'**
  String get securityConfirmPinDescription;

  /// Toggle label for biometric sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign in with Biometrics'**
  String get securitySignInWithBiometrics;

  /// Biometric prompt title when unlocking the app
  ///
  /// In en, this message translates to:
  /// **'Unlock BigPay'**
  String get securityUnlockBigPay;

  /// Toggle label for biometric transaction confirmation
  ///
  /// In en, this message translates to:
  /// **'Transact with Biometrics'**
  String get securityTransactWithBiometrics;

  /// Help page title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// Link to call support
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get helpCallUs;

  /// Link to email support
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get helpEmailUs;

  /// Link to contact support via WhatsApp
  ///
  /// In en, this message translates to:
  /// **'Contact us via WhatsApp'**
  String get helpContactWhatsApp;

  /// Complaints list page title
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaintsTitle;

  /// Button to start a new complaint
  ///
  /// In en, this message translates to:
  /// **'New Complaint'**
  String get complaintsNewComplaint;

  /// Fallback title for a complaint with no subject or category
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaintsFallbackTitle;

  /// Empty-state heading on the complaints list
  ///
  /// In en, this message translates to:
  /// **'No complaints yet'**
  String get complaintsEmptyTitle;

  /// Empty-state message on the complaints list
  ///
  /// In en, this message translates to:
  /// **'Raised complaints and their replies will appear here.'**
  String get complaintsEmptySubtitle;

  /// Empty-state message on a complaint's detail/chat trail
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get complaintsNoMessages;

  /// Placeholder for the complaint reply composer
  ///
  /// In en, this message translates to:
  /// **'Type a reply…'**
  String get complaintsReplyPlaceholder;

  /// Tooltip on the complaint reply send button
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get complaintsSendMessageTooltip;

  /// More/account page title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreAccountTitle;

  /// Menu item linking to beneficiaries
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get moreBeneficiaries;

  /// Menu item linking to the new-complaint form
  ///
  /// In en, this message translates to:
  /// **'Submit a Complaint'**
  String get moreSubmitComplaint;

  /// Menu item linking to the privacy statement
  ///
  /// In en, this message translates to:
  /// **'Privacy Statement'**
  String get morePrivacyStatement;

  /// Sign-out menu item, dialog title, and confirm button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get moreSignOutTitle;

  /// Sign-out confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get moreSignOutConfirm;

  /// Label for the theme switcher
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get moreThemeLabel;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get moreThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get moreThemeDark;

  /// System-default theme/language option
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get moreThemeAuto;

  /// Fallback for a missing value
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNotAvailable;

  /// Dashboard header greeting above the user's name
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get dashboardWelcomeBack;

  /// Tooltip on the dashboard notifications bell
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get dashboardNotificationsTooltip;

  /// Heading above the most-used services carousel
  ///
  /// In en, this message translates to:
  /// **'Most used services'**
  String get dashboardMostUsedServices;

  /// Heading above the services grid
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get dashboardServicesHeader;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get commonArchive;

  /// No description provided for @commonAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get commonAddNew;

  /// No description provided for @commonShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get commonShowResults;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonDateFormatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YY'**
  String get commonDateFormatPlaceholder;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @walletsVirtualWalletFallback.
  ///
  /// In en, this message translates to:
  /// **'Virtual Wallet'**
  String get walletsVirtualWalletFallback;

  /// No description provided for @walletsRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get walletsRecentTransactions;

  /// No description provided for @walletsChooseDateRange.
  ///
  /// In en, this message translates to:
  /// **'Choose a date range'**
  String get walletsChooseDateRange;

  /// No description provided for @walletsStatementEmailNotice.
  ///
  /// In en, this message translates to:
  /// **'The statement will be sent to your email address'**
  String get walletsStatementEmailNotice;

  /// No description provided for @walletsDateFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Date From'**
  String get walletsDateFromLabel;

  /// No description provided for @walletsDateToLabel.
  ///
  /// In en, this message translates to:
  /// **'Date To'**
  String get walletsDateToLabel;

  /// No description provided for @walletsViewStatement.
  ///
  /// In en, this message translates to:
  /// **'View Statement'**
  String get walletsViewStatement;

  /// No description provided for @walletsFundWalletDemo.
  ///
  /// In en, this message translates to:
  /// **'Fund Wallet'**
  String get walletsFundWalletDemo;

  /// No description provided for @walletsNoTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get walletsNoTransactionsYet;

  /// No description provided for @walletsNoTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your financial journey starts here. Once you send or receive funds, your activity will appear in this space'**
  String get walletsNoTransactionsSubtitle;

  /// No description provided for @walletsAddCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get walletsAddCardTitle;

  /// No description provided for @walletsDebitLabel.
  ///
  /// In en, this message translates to:
  /// **'DEBIT'**
  String get walletsDebitLabel;

  /// No description provided for @walletsCardHolderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get walletsCardHolderNameLabel;

  /// No description provided for @walletsCardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get walletsCardNumberLabel;

  /// No description provided for @walletsCvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get walletsCvvLabel;

  /// No description provided for @walletsExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get walletsExpiryDateLabel;

  /// No description provided for @walletsBigPayVirtualWalletDemo.
  ///
  /// In en, this message translates to:
  /// **'BigPay Virtual Wallet'**
  String get walletsBigPayVirtualWalletDemo;

  /// No description provided for @walletsBalanceDemo.
  ///
  /// In en, this message translates to:
  /// **'Balance - GHS 20,000.00'**
  String get walletsBalanceDemo;

  /// No description provided for @walletsAddMomoMiniTitle.
  ///
  /// In en, this message translates to:
  /// **'Add MoMo Wallet'**
  String get walletsAddMomoMiniTitle;

  /// No description provided for @walletsAddMomoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Mobile Money Wallet'**
  String get walletsAddMomoTitle;

  /// No description provided for @walletsAddMomoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Securely connect your mobile money wallet for instant wallet top-ups and seamless payments.'**
  String get walletsAddMomoSubtitle;

  /// No description provided for @walletsChooseNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose Network'**
  String get walletsChooseNetworkLabel;

  /// No description provided for @walletsMomoOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to +233********219'**
  String get walletsMomoOtpSubtitle;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDateLabel;

  /// No description provided for @commonBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get commonBackToHome;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get historyTitle;

  /// No description provided for @historyFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter transactions'**
  String get historyFilterTooltip;

  /// Tooltip on the history filter button when a filter is active
  ///
  /// In en, this message translates to:
  /// **'Filter: {filter}'**
  String historyFilterActiveTooltip(String filter);

  /// Empty-state label when a search query matches nothing
  ///
  /// In en, this message translates to:
  /// **'No transactions match \"{query}\"'**
  String historyNoMatchQuery(String query);

  /// Empty-state label when an active filter matches nothing
  ///
  /// In en, this message translates to:
  /// **'No {filter} transactions found'**
  String historyNoFilterResults(String filter);

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed transactions will appear here.'**
  String get historyEmptySubtitle;

  /// No description provided for @historyFilterByService.
  ///
  /// In en, this message translates to:
  /// **'Filter by service'**
  String get historyFilterByService;

  /// No description provided for @historyClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get historyClearFilter;

  /// No description provided for @historyNoServicesToFilter.
  ///
  /// In en, this message translates to:
  /// **'No services to filter by yet.'**
  String get historyNoServicesToFilter;

  /// No description provided for @historyServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get historyServiceLabel;

  /// No description provided for @historyTransactionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get historyTransactionIdLabel;

  /// No description provided for @historySubmitComplain.
  ///
  /// In en, this message translates to:
  /// **'Submit a Complain'**
  String get historySubmitComplain;

  /// No description provided for @historyTransactionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful'**
  String get historyTransactionSuccessful;

  /// No description provided for @historyTransactionCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your transaction is complete'**
  String get historyTransactionCompleteSubtitle;

  /// No description provided for @historyTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get historyTransactionFailed;

  /// No description provided for @historyTransactionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Transaction Receipt'**
  String get historyTransactionReceipt;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get commonNoMatches;

  /// No description provided for @beneficiariesRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove beneficiary'**
  String get beneficiariesRemoveTitle;

  /// Confirmation dialog message before removing a beneficiary
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your beneficiaries?'**
  String beneficiariesRemoveConfirm(String name);

  /// Empty-state label when a beneficiary search query matches nothing
  ///
  /// In en, this message translates to:
  /// **'No beneficiaries match \"{query}\"'**
  String beneficiariesNoMatchQuery(String query);

  /// No description provided for @beneficiariesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No beneficiary yet'**
  String get beneficiariesEmptyTitle;

  /// No description provided for @beneficiariesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add beneficiaries to see them here'**
  String get beneficiariesEmptySubtitle;

  /// No description provided for @beneficiariesAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Beneficiary'**
  String get beneficiariesAddTitle;

  /// No description provided for @beneficiariesAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a service to save a beneficiary for'**
  String get beneficiariesAddSubtitle;

  /// No description provided for @beneficiariesEmptyServices.
  ///
  /// In en, this message translates to:
  /// **'Empty Services'**
  String get beneficiariesEmptyServices;

  /// No description provided for @beneficiariesFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get beneficiariesFallbackName;

  /// No description provided for @beneficiariesDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Details'**
  String get beneficiariesDetailsTitle;

  /// No description provided for @beneficiariesRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Beneficiary'**
  String get beneficiariesRemoveButton;

  /// No description provided for @beneficiariesRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get beneficiariesRecipientLabel;

  /// No description provided for @kycIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s get you verified'**
  String get kycIntroTitle;

  /// No description provided for @kycIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your Ghana Card details now for a safer, faster experience.'**
  String get kycIntroSubtitle;

  /// No description provided for @kycGhanaCardInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Ghana Card Information'**
  String get kycGhanaCardInfoTitle;

  /// No description provided for @kycPersonalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get kycPersonalInfoTitle;

  /// No description provided for @kycSelectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select ...'**
  String get kycSelectPlaceholder;

  /// No description provided for @kycNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality *'**
  String get kycNationalityLabel;

  /// No description provided for @kycVerificationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful!'**
  String get kycVerificationSuccessTitle;

  /// No description provided for @kycVerificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get kycVerificationFailedTitle;

  /// No description provided for @kycContactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get kycContactInfoTitle;

  /// No description provided for @kycStreetAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Street Address *'**
  String get kycStreetAddressLabel;

  /// No description provided for @kycDigitalAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Digital Address'**
  String get kycDigitalAddressLabel;

  /// No description provided for @kycResidentialAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Residential Address'**
  String get kycResidentialAddressTitle;

  /// No description provided for @kycStateRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'State / Region *'**
  String get kycStateRegionLabel;

  /// No description provided for @kycDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get kycDistrictLabel;

  /// No description provided for @kycTownCityLabel.
  ///
  /// In en, this message translates to:
  /// **'Town / City *'**
  String get kycTownCityLabel;

  /// No description provided for @kycDigitalAddressRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Digital Address *'**
  String get kycDigitalAddressRequiredLabel;

  /// No description provided for @kycCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get kycCountryLabel;

  /// No description provided for @kycIssueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Date *'**
  String get kycIssueDateLabel;

  /// No description provided for @kycExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date *'**
  String get kycExpiryDateLabel;

  /// No description provided for @kycTakeSelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a Quick Selfie'**
  String get kycTakeSelfieTitle;

  /// No description provided for @kycSelfieMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will match your photo against the National Identification Authority (NIA) database to verify it\'s really you'**
  String get kycSelfieMatchSubtitle;

  /// No description provided for @kycIdentityVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get kycIdentityVerificationTitle;

  /// No description provided for @kycScanCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your Ghana Card front & back'**
  String get kycScanCardSubtitle;

  /// No description provided for @kycFullyEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fully encrypted'**
  String get kycFullyEncryptedTitle;

  /// No description provided for @kycDataEncryptedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and secure'**
  String get kycDataEncryptedSubtitle;

  /// No description provided for @kycVerifyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Verify Photo'**
  String get kycVerifyPhoto;

  /// No description provided for @kycRetakePicture.
  ///
  /// In en, this message translates to:
  /// **'Retake Picture'**
  String get kycRetakePicture;

  /// No description provided for @kycReviewPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your photo'**
  String get kycReviewPhotoTitle;

  /// No description provided for @kycReviewPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure your face is clearly visible before continuing'**
  String get kycReviewPhotoSubtitle;

  /// No description provided for @kycFaceClearlyVisible.
  ///
  /// In en, this message translates to:
  /// **'Face clearly visible'**
  String get kycFaceClearlyVisible;

  /// No description provided for @kycNoObstructions.
  ///
  /// In en, this message translates to:
  /// **'No obstructions or glasses'**
  String get kycNoObstructions;

  /// No description provided for @kycWellLit.
  ///
  /// In en, this message translates to:
  /// **'Well lit'**
  String get kycWellLit;

  /// No description provided for @kycEvenLighting.
  ///
  /// In en, this message translates to:
  /// **'Even lighting, no harsh shadows'**
  String get kycEvenLighting;

  /// No description provided for @kycSlightBlur.
  ///
  /// In en, this message translates to:
  /// **'Slight blur detected'**
  String get kycSlightBlur;

  /// No description provided for @kycRetakeIfUnclear.
  ///
  /// In en, this message translates to:
  /// **'Retake if image feels unclear'**
  String get kycRetakeIfUnclear;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// Empty-state label when a service search query matches nothing
  ///
  /// In en, this message translates to:
  /// **'No services match \"{query}\"'**
  String servicesNoMatchQuery(String query);

  /// No description provided for @servicesNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No Services found'**
  String get servicesNoneFound;

  /// No description provided for @servicesVerifyIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get servicesVerifyIdentityTitle;

  /// No description provided for @servicesVerifyIdentityMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your profile to start sending, receiving, and managing your money securely.'**
  String get servicesVerifyIdentityMessage;

  /// No description provided for @servicesPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'60% Complete'**
  String get servicesPercentComplete;

  /// No description provided for @servicesStartVerification.
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get servicesStartVerification;

  /// No description provided for @summaryBeneficiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Summary'**
  String get summaryBeneficiaryTitle;

  /// No description provided for @summaryTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Summary'**
  String get summaryTransactionTitle;

  /// No description provided for @summaryBeneficiaryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm the beneficiary details before you save'**
  String get summaryBeneficiaryConfirm;

  /// No description provided for @summaryTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Kindly confirm the transaction details before you proceed'**
  String get summaryTransactionConfirm;

  /// No description provided for @summarySaveBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Save Beneficiary'**
  String get summarySaveBeneficiary;

  /// No description provided for @summaryBeneficiarySavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary saved.'**
  String get summaryBeneficiarySavedMessage;

  /// No description provided for @feedbackSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been submitted.'**
  String get feedbackSubmittedMessage;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encountered a problem? Tell us what went wrong, and our support team will get straight to work to resolve it for you.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackResponseTimeNotice.
  ///
  /// In en, this message translates to:
  /// **'Our team typically responds within 2 hours.'**
  String get feedbackResponseTimeNotice;

  /// No description provided for @feedbackSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get feedbackSendMessage;

  /// No description provided for @feedbackSelectCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get feedbackSelectCategoryLabel;

  /// No description provided for @feedbackCategorySearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get feedbackCategorySearchPlaceholder;

  /// No description provided for @feedbackSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get feedbackSubjectLabel;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Details of your challenge here'**
  String get feedbackMessagePlaceholder;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsNewSection.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNewSection;

  /// No description provided for @notificationsEarlierSection.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsEarlierSection;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates about your account and transactions will appear here.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @appErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'App Error'**
  String get appErrorTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @walkthroughCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a New Account'**
  String get walkthroughCreateAccount;

  /// No description provided for @walkthroughAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account? '**
  String get walkthroughAlreadyHaveAccount;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonNoOptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get commonNoOptionsAvailable;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get commonNoResultsFound;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @payeeNoSavedRecipientsTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved recipients'**
  String get payeeNoSavedRecipientsTitle;

  /// No description provided for @payeeNoSavedRecipientsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no saved recipients for this service yet.'**
  String get payeeNoSavedRecipientsMessage;

  /// No description provided for @payeeRecipientFallback.
  ///
  /// In en, this message translates to:
  /// **'recipient'**
  String get payeeRecipientFallback;

  /// No description provided for @walletsVirtualBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Virtual Wallet Balance'**
  String get walletsVirtualBalanceLabel;

  /// No description provided for @walletsGenericFallback.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletsGenericFallback;

  /// No description provided for @walletsHideBalanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get walletsHideBalanceTooltip;

  /// No description provided for @walletsShowBalanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get walletsShowBalanceTooltip;

  /// No description provided for @walletsViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get walletsViewDetails;

  /// No description provided for @pinAuthDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide your 6-digit PIN to authorize this action and keep your account secure.'**
  String get pinAuthDefaultDescription;

  /// No description provided for @otpAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide your 6-digit shortcode send to your phone number to authorize this transaction'**
  String get otpAuthDescription;

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get otpResendCode;

  /// Countdown before the OTP resend link becomes active, e.g. 'Resend code in 0:45'
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String otpResendCodeIn(String time);

  /// Supporting line under the logo on the auth pages' wide-screen brand panel
  ///
  /// In en, this message translates to:
  /// **'Send, receive, and manage your money — simply and securely.'**
  String get authBrandTagline;

  /// Sign-up flow step label: entering the phone number
  ///
  /// In en, this message translates to:
  /// **'Your number'**
  String get stepSignupPhone;

  /// Sign-up flow step label: confirming the OTP code
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get stepSignupCode;

  /// Sign-up flow step label: creating the password
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get stepSignupPassword;

  /// Sign-up flow step label: setting the secure phrase
  ///
  /// In en, this message translates to:
  /// **'Security phrase'**
  String get stepSignupSecurity;

  /// Sign-up flow step label: setting the security PIN
  ///
  /// In en, this message translates to:
  /// **'Set your PIN'**
  String get stepSignupPin;

  /// Forgot-password flow step label: verifying identity
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you'**
  String get stepForgotVerify;

  /// Forgot-password flow step label: confirming the OTP code
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get stepForgotCode;

  /// Forgot-password flow step label: setting the new password
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get stepForgotPassword;

  /// KYC flow step label: Ghana Card details
  ///
  /// In en, this message translates to:
  /// **'Your ID'**
  String get stepKycId;

  /// KYC flow step label: taking a selfie
  ///
  /// In en, this message translates to:
  /// **'Quick selfie'**
  String get stepKycSelfie;

  /// KYC flow step label: contact information
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get stepKycContact;

  /// Sign-in flow step label: entering credentials
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get stepSigninDetails;

  /// Sign-in flow step label: answering the secure phrase
  ///
  /// In en, this message translates to:
  /// **'Security check'**
  String get stepSigninSecurity;

  /// Sign-in flow step label: confirming the OTP code
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get stepSigninCode;

  /// No description provided for @connectivityLostTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get connectivityLostTitle;

  /// No description provided for @connectivityLostMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your network settings and try again.'**
  String get connectivityLostMessage;

  /// No description provided for @connectivityRestoredTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re back online'**
  String get connectivityRestoredTitle;

  /// No description provided for @connectivityRestoredMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection restored successfully.'**
  String get connectivityRestoredMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'pcm',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pcm':
      return AppLocalizationsPcm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
