// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonOk => 'موافق';

  @override
  String get commonLogin => 'تسجيل الدخول';

  @override
  String get commonChange => 'تغيير';

  @override
  String get commonSelectPlaceholder => 'اختر...';

  @override
  String get commonPhoneNumberLabel => 'رقم الهاتف';

  @override
  String get commonPasswordLabel => 'كلمة المرور';

  @override
  String get commonPasswordPlaceholder => 'كلمة المرور';

  @override
  String get commonConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get commonBiometricLogin => 'تسجيل الدخول بالبصمة';

  @override
  String get commonForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authSignUpTitle => 'إنشاء حساب';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignInLink => 'تسجيل الدخول';

  @override
  String get authTermsPrefix => 'بالنقر على متابعة، فإنك توافق على ';

  @override
  String get authTermsOfUse => 'شروط الاستخدام';

  @override
  String get authAnd => ' و ';

  @override
  String get authPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get authEnterOtp => 'أدخل رمز التحقق';

  @override
  String get authCreatePasswordTitle => 'إنشاء كلمة مرور';

  @override
  String get authSavePassword => 'حفظ كلمة المرور';

  @override
  String get authPasswordRequirements =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل وتشمل حروفًا وأرقامًا ورموزًا خاصة (مثل !\$@%).';

  @override
  String get passwordRuleMinLength => 'At least 6 characters';

  @override
  String get passwordRuleUppercase => 'At least one uppercase letter';

  @override
  String get passwordRuleLowercase => 'At least one lowercase letter';

  @override
  String get passwordRuleNumber => 'At least one number';

  @override
  String get passwordRuleSpecialChar => 'At least one special character';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get authSetSecurityPinTitle => 'تعيين رمز الأمان';

  @override
  String get authSetPinSubtitle =>
      'عيّن رمزًا مكونًا من 4 أرقام لتفويض المدفوعات والحفاظ على أمان محفظتك.';

  @override
  String get authWelcomeAboardTitle => 'مرحبًا بك!';

  @override
  String get authGetStarted => 'ابدأ الآن';

  @override
  String get authEnterPin => 'أدخل رمز PIN المكوّن من 6 أرقام';

  @override
  String get authConfirmPin => 'تأكيد رمز PIN';

  @override
  String get authCreateSecurePhraseTitle => 'إنشاء عبارة أمان';

  @override
  String get authSecurePhraseSubtitle =>
      'خصّص سؤالك وجوابك الخاص للتحقق الأسرع والمدفوعات الرقمية الأكثر أمانًا.';

  @override
  String get authChooseQuestionLabel => 'اختر سؤالًا';

  @override
  String get authAnswerToQuestionLabel => 'الإجابة على السؤال';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get authSignUpLink => 'إنشاء حساب';

  @override
  String get authWelcomeBackPrefix => 'مرحبًا بعودتك، ';

  @override
  String get authEnterPasswordContinueSuffix =>
      '. \nأدخل كلمة المرور للمتابعة.';

  @override
  String get authPasswordRequiredTitle => 'كلمة المرور مطلوبة';

  @override
  String get authPasswordRequiredMessage =>
      'سجّل الدخول بكلمة المرور أولاً للاستمتاع بتسجيل الدخول بالبصمة.';

  @override
  String get authPasswordRequiredError => 'كلمة المرور مطلوبة';

  @override
  String get authUseDifferentAccount => 'لست أنت؟ استخدم حسابًا آخر';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get authSignInToContinue => 'سجّل الدخول للمتابعة';

  @override
  String get authEnterPasswordPlaceholder => 'أدخل كلمة المرور';

  @override
  String get authEnterSecurePhraseTitle => 'أدخل عبارة الأمان الخاصة بك';

  @override
  String get authUnlockWithBiometrics => 'فتح القفل بالبصمة';

  @override
  String get authLoginWithPassword => 'تسجيل الدخول بكلمة المرور';

  @override
  String get authUnlockWithBiometricsTooltip => 'فتح القفل بالبصمة';

  @override
  String get authForgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get authAnswerToSecurePhraseLabel => 'الإجابة على عبارة الأمان';

  @override
  String get authForgotSecretAnswer => 'نسيت الإجابة السرية؟';

  @override
  String get authSuccessfulTitle => 'تم بنجاح';

  @override
  String get authPasswordResetSuccessMessage =>
      'تمت إعادة تعيين كلمة المرور بنجاح. يمكنك الآن استخدام كلمة المرور الجديدة لتسجيل الدخول';

  @override
  String get authForgotSecurePhraseTitle => 'نسيت عبارة الأمان';

  @override
  String get authEmailAddressLabel => 'البريد الإلكتروني';

  @override
  String get commonServiceUnavailableTitle => 'الخدمة غير متوفرة';

  @override
  String get commonServiceUnavailableMessage => 'هذه الخدمة غير متوفرة حاليًا';

  @override
  String get profileFirstNameLabel => 'الاسم الأول *';

  @override
  String get profileMiddleNameLabel => 'الاسم الأوسط';

  @override
  String get profileLastNameLabel => 'اسم العائلة *';

  @override
  String get profileEmailAddressLabel => 'البريد الإلكتروني *';

  @override
  String get profileDateOfBirthLabel => 'تاريخ الميلاد *';

  @override
  String get profileGenderLabel => 'الجنس *';

  @override
  String get profileNationalityLabel => 'الجنسية';

  @override
  String get securityTitle => 'الأمان';

  @override
  String get securityBiometricsUnavailableTitle => 'البصمة غير متوفرة';

  @override
  String get securityBiometricsUnavailableMessage =>
      'يرجى إعداد Face ID أو بصمة الإصبع على جهازك أولاً.';

  @override
  String get securityConfirmBiometricAccess => 'أكّد لتفعيل الوصول بالبصمة';

  @override
  String get securityEnterPinTooltip => 'أدخل رمز الأمان';

  @override
  String get securityConfirmPinDescription =>
      'أكّد رمز PIN الخاص بك لتحديث إعدادات البصمة.';

  @override
  String get securitySignInWithBiometrics => 'تسجيل الدخول بالبصمة';

  @override
  String get securityUnlockBigPay => 'Unlock BigPay';

  @override
  String get securityTransactWithBiometrics => 'إجراء المعاملات بالبصمة';

  @override
  String get helpTitle => 'المساعدة';

  @override
  String get helpCallUs => 'اتصل بنا';

  @override
  String get helpEmailUs => 'راسلنا عبر البريد الإلكتروني';

  @override
  String get helpContactWhatsApp => 'تواصل معنا عبر واتساب';

  @override
  String get complaintsTitle => 'الشكاوى';

  @override
  String get complaintsNewComplaint => 'شكوى جديدة';

  @override
  String get complaintsFallbackTitle => 'شكوى';

  @override
  String get complaintsEmptyTitle => 'لا توجد شكاوى بعد';

  @override
  String get complaintsEmptySubtitle => 'ستظهر الشكاوى المقدمة وردودها هنا.';

  @override
  String get complaintsNoMessages => 'لا توجد رسائل بعد.';

  @override
  String get complaintsReplyPlaceholder => 'اكتب ردًا…';

  @override
  String get complaintsSendMessageTooltip => 'إرسال الرسالة';

  @override
  String get moreAccountTitle => 'الحساب';

  @override
  String get moreBeneficiaries => 'المستفيدون';

  @override
  String get moreSubmitComplaint => 'تقديم شكوى';

  @override
  String get morePrivacyStatement => 'سياسة الخصوصية';

  @override
  String get moreSignOutTitle => 'تسجيل الخروج';

  @override
  String get moreSignOutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get moreThemeLabel => 'المظهر';

  @override
  String get moreThemeLight => 'فاتح';

  @override
  String get moreThemeDark => 'داكن';

  @override
  String get moreThemeAuto => 'تلقائي';

  @override
  String get commonNotAvailable => 'غير متوفر';

  @override
  String get dashboardWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get dashboardNotificationsTooltip => 'الإشعارات';

  @override
  String get dashboardMostUsedServices => 'الخدمات الأكثر استخدامًا';

  @override
  String get dashboardServicesHeader => 'الخدمات';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonArchive => 'أرشفة';

  @override
  String get commonAddNew => 'إضافة جديد';

  @override
  String get commonShowResults => 'عرض النتائج';

  @override
  String get commonSuccess => 'نجاح';

  @override
  String get commonDateFormatPlaceholder => 'يوم/شهر/سنة';

  @override
  String get walletsTitle => 'المحافظ';

  @override
  String get walletsVirtualWalletFallback => 'المحفظة الافتراضية';

  @override
  String get walletsRecentTransactions => 'أحدث المعاملات';

  @override
  String get walletsChooseDateRange => 'اختر نطاقًا زمنيًا';

  @override
  String get walletsStatementEmailNotice =>
      'سيتم إرسال الكشف إلى بريدك الإلكتروني';

  @override
  String get walletsDateFromLabel => 'من تاريخ';

  @override
  String get walletsDateToLabel => 'إلى تاريخ';

  @override
  String get walletsViewStatement => 'عرض الكشف';

  @override
  String get walletsFundWalletDemo => 'تعبئة المحفظة';

  @override
  String get walletsNoTransactionsYet => 'لا توجد معاملات بعد';

  @override
  String get walletsNoTransactionsSubtitle =>
      'رحلتك المالية تبدأ هنا. بمجرد إرسال أو استلام الأموال، سيظهر نشاطك في هذا القسم';

  @override
  String get walletsAddCardTitle => 'إضافة بطاقة';

  @override
  String get walletsDebitLabel => 'خصم';

  @override
  String get walletsCardHolderNameLabel => 'اسم حامل البطاقة';

  @override
  String get walletsCardNumberLabel => 'رقم البطاقة';

  @override
  String get walletsCvvLabel => 'رمز التحقق CVV';

  @override
  String get walletsExpiryDateLabel => 'تاريخ الانتهاء';

  @override
  String get walletsBigPayVirtualWalletDemo => 'محفظة BigPay الافتراضية';

  @override
  String get walletsBalanceDemo => 'الرصيد - 20,000.00 GHS';

  @override
  String get walletsAddMomoMiniTitle => 'إضافة محفظة موبايل موني';

  @override
  String get walletsAddMomoTitle => 'إضافة محفظة الأموال عبر الهاتف المحمول';

  @override
  String get walletsAddMomoSubtitle =>
      'اربط محفظة الأموال عبر الهاتف المحمول بأمان لإعادة الشحن الفوري والمدفوعات السلسة.';

  @override
  String get walletsChooseNetworkLabel => 'اختر الشبكة';

  @override
  String get walletsMomoOtpSubtitle =>
      'أدخل الرمز المكوّن من 6 أرقام المُرسل إلى +233********219';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDateLabel => 'التاريخ';

  @override
  String get commonBackToHome => 'العودة إلى الرئيسية';

  @override
  String get historyTitle => 'المعاملات';

  @override
  String get historyFilterTooltip => 'تصفية المعاملات';

  @override
  String historyFilterActiveTooltip(String filter) {
    return 'التصفية: $filter';
  }

  @override
  String historyNoMatchQuery(String query) {
    return 'لا توجد معاملات مطابقة لـ \"$query\"';
  }

  @override
  String historyNoFilterResults(String filter) {
    return 'لم يتم العثور على معاملات $filter';
  }

  @override
  String get historyEmptySubtitle => 'ستظهر المعاملات المكتملة هنا.';

  @override
  String get historyFilterByService => 'تصفية حسب الخدمة';

  @override
  String get historyClearFilter => 'مسح التصفية';

  @override
  String get historyNoServicesToFilter => 'لا توجد خدمات للتصفية بعد.';

  @override
  String get historyServiceLabel => 'الخدمة';

  @override
  String get historyTransactionIdLabel => 'رقم المعاملة';

  @override
  String get historySubmitComplain => 'تقديم شكوى';

  @override
  String get historyTransactionSuccessful => 'تمت المعاملة بنجاح';

  @override
  String get historyTransactionCompleteSubtitle => 'معاملتك مكتملة';

  @override
  String get historyTransactionFailed => 'فشلت المعاملة';

  @override
  String get historyTransactionReceipt => 'إيصال المعاملة';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonNoMatches => 'لا توجد نتائج مطابقة';

  @override
  String get beneficiariesRemoveTitle => 'إزالة المستفيد';

  @override
  String beneficiariesRemoveConfirm(String name) {
    return 'هل تريد إزالة $name من قائمة المستفيدين؟';
  }

  @override
  String beneficiariesNoMatchQuery(String query) {
    return 'لا يوجد مستفيدون مطابقون لـ \"$query\"';
  }

  @override
  String get beneficiariesEmptyTitle => 'لا يوجد مستفيدون بعد';

  @override
  String get beneficiariesEmptySubtitle => 'أضف مستفيدين لتظهر هنا';

  @override
  String get beneficiariesAddTitle => 'إضافة مستفيد';

  @override
  String get beneficiariesAddSubtitle => 'اختر خدمة لحفظ مستفيد لها';

  @override
  String get beneficiariesEmptyServices => 'لا توجد خدمات';

  @override
  String get beneficiariesFallbackName => 'مستفيد';

  @override
  String get beneficiariesDetailsTitle => 'تفاصيل المستفيد';

  @override
  String get beneficiariesRemoveButton => 'إزالة المستفيد';

  @override
  String get beneficiariesRecipientLabel => 'المستلم';

  @override
  String get kycIntroTitle => 'لنقم بالتحقق من حسابك';

  @override
  String get kycIntroSubtitle =>
      'أكّد بيانات بطاقة غانا الخاصة بك الآن لتجربة أكثر أمانًا وسرعة.';

  @override
  String get kycGhanaCardInfoTitle => 'معلومات بطاقة غانا';

  @override
  String get kycPersonalInfoTitle => 'المعلومات الشخصية';

  @override
  String get kycSelectPlaceholder => 'اختر...';

  @override
  String get kycNationalityLabel => 'الجنسية *';

  @override
  String get kycVerificationSuccessTitle => 'تم التحقق بنجاح!';

  @override
  String get kycVerificationFailedTitle => 'فشل التحقق';

  @override
  String get kycContactInfoTitle => 'معلومات الاتصال';

  @override
  String get kycStreetAddressLabel => 'عنوان الشارع *';

  @override
  String get kycDigitalAddressLabel => 'العنوان الرقمي';

  @override
  String get kycResidentialAddressTitle => 'عنوان السكن';

  @override
  String get kycStateRegionLabel => 'الولاية / المنطقة *';

  @override
  String get kycDistrictLabel => 'المقاطعة';

  @override
  String get kycTownCityLabel => 'المدينة / البلدة *';

  @override
  String get kycDigitalAddressRequiredLabel => 'العنوان الرقمي *';

  @override
  String get kycCountryLabel => 'الدولة *';

  @override
  String get kycIssueDateLabel => 'تاريخ الإصدار *';

  @override
  String get kycExpiryDateLabel => 'تاريخ الانتهاء *';

  @override
  String get kycTakeSelfieTitle => 'التقط صورة سيلفي سريعة';

  @override
  String get kycSelfieMatchSubtitle =>
      'سنقوم بمطابقة صورتك مع قاعدة بيانات الهيئة الوطنية للهوية (NIA) للتحقق من أنها أنت حقًا';

  @override
  String get kycIdentityVerificationTitle => 'التحقق من الهوية';

  @override
  String get kycScanCardSubtitle =>
      'امسح الوجهين الأمامي والخلفي لبطاقة غانا الخاصة بك';

  @override
  String get kycFullyEncryptedTitle => 'مشفّر بالكامل';

  @override
  String get kycDataEncryptedSubtitle => 'بياناتك مشفّرة وآمنة';

  @override
  String get kycVerifyPhoto => 'تحقق من الصورة';

  @override
  String get kycRetakePicture => 'إعادة التقاط الصورة';

  @override
  String get kycReviewPhotoTitle => 'راجع صورتك';

  @override
  String get kycReviewPhotoSubtitle => 'تأكد من ظهور وجهك بوضوح قبل المتابعة';

  @override
  String get kycFaceClearlyVisible => 'الوجه واضح تمامًا';

  @override
  String get kycNoObstructions => 'لا توجد عوائق أو نظارات';

  @override
  String get kycWellLit => 'إضاءة جيدة';

  @override
  String get kycEvenLighting => 'إضاءة متساوية، بلا ظلال قاسية';

  @override
  String get kycSlightBlur => 'تم اكتشاف ضبابية طفيفة';

  @override
  String get kycRetakeIfUnclear => 'أعد الالتقاط إذا بدت الصورة غير واضحة';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String servicesNoMatchQuery(String query) {
    return 'لا توجد خدمات مطابقة لـ \"$query\"';
  }

  @override
  String get servicesNoneFound => 'لم يتم العثور على خدمات';

  @override
  String get servicesVerifyIdentityTitle => 'تحقق من هويتك';

  @override
  String get servicesVerifyIdentityMessage =>
      'أكمل إعداد ملفك الشخصي لبدء إرسال واستقبال وإدارة أموالك بأمان.';

  @override
  String get servicesPercentComplete => 'اكتمل 60%';

  @override
  String get servicesStartVerification => 'بدء التحقق';

  @override
  String get summaryBeneficiaryTitle => 'ملخص المستفيد';

  @override
  String get summaryTransactionTitle => 'ملخص المعاملة';

  @override
  String get summaryBeneficiaryConfirm => 'أكّد بيانات المستفيد قبل الحفظ';

  @override
  String get summaryTransactionConfirm =>
      'يرجى تأكيد تفاصيل المعاملة قبل المتابعة';

  @override
  String get summarySaveBeneficiary => 'حفظ المستفيد';

  @override
  String get summaryBeneficiarySavedMessage => 'تم حفظ المستفيد.';

  @override
  String get feedbackSubmittedMessage => 'تم إرسال شكواك.';

  @override
  String get feedbackTitle => 'الإبلاغ عن مشكلة';

  @override
  String get feedbackSubtitle =>
      'هل واجهت مشكلة؟ أخبرنا بما حدث، وسيبدأ فريق الدعم بالعمل فورًا لحلها.';

  @override
  String get feedbackResponseTimeNotice => 'عادةً ما يرد فريقنا خلال ساعتين.';

  @override
  String get feedbackSendMessage => 'إرسال الرسالة';

  @override
  String get feedbackSelectCategoryLabel => 'اختر فئة';

  @override
  String get feedbackCategorySearchPlaceholder => 'بحث...';

  @override
  String get feedbackSubjectLabel => 'الموضوع';

  @override
  String get feedbackMessageLabel => 'الرسالة';

  @override
  String get feedbackMessagePlaceholder => 'تفاصيل مشكلتك هنا';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsNewSection => 'جديد';

  @override
  String get notificationsEarlierSection => 'سابقًا';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptySubtitle => 'ستظهر تحديثات حسابك ومعاملاتك هنا.';

  @override
  String get appErrorTitle => 'خطأ في التطبيق';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get walkthroughCreateAccount => 'إنشاء حساب جديد';

  @override
  String get walkthroughAlreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navHistory => 'السجل';

  @override
  String get navMore => 'المزيد';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonNoOptionsAvailable => 'لا توجد خيارات متاحة';

  @override
  String get commonSelect => 'اختر';

  @override
  String get commonNoResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get payeeNoSavedRecipientsTitle => 'لا يوجد مستلمون محفوظون';

  @override
  String get payeeNoSavedRecipientsMessage =>
      'لا يوجد مستلمون محفوظون لهذه الخدمة بعد.';

  @override
  String get payeeRecipientFallback => 'المستلم';

  @override
  String get walletsVirtualBalanceLabel => 'رصيد المحفظة الافتراضية';

  @override
  String get walletsGenericFallback => 'المحفظة';

  @override
  String get walletsHideBalanceTooltip => 'إخفاء الرصيد';

  @override
  String get walletsShowBalanceTooltip => 'إظهار الرصيد';

  @override
  String get walletsViewDetails => 'عرض التفاصيل';

  @override
  String get pinAuthDefaultDescription =>
      'يرجى إدخال رمز PIN المكوّن من 6 أرقام لتفويض هذا الإجراء والحفاظ على أمان حسابك.';

  @override
  String get otpAuthDescription =>
      'يرجى إدخال الرمز المكوّن من 6 أرقام المُرسل إلى رقم هاتفك لتفويض هذه المعاملة';

  @override
  String get otpResendCode => 'إعادة إرسال الرمز';

  @override
  String otpResendCodeIn(String time) {
    return 'إعادة إرسال الرمز خلال $time';
  }

  @override
  String get authBrandTagline => 'أرسل واستقبل وأدر أموالك — ببساطة وأمان.';

  @override
  String get stepSignupPhone => 'Your number';

  @override
  String get stepSignupCode => 'Confirm code';

  @override
  String get stepSignupPassword => 'Create password';

  @override
  String get stepSignupSecurity => 'Security phrase';

  @override
  String get stepSignupPin => 'Set your PIN';

  @override
  String get stepForgotVerify => 'Verify it\'s you';

  @override
  String get stepForgotCode => 'Confirm code';

  @override
  String get stepForgotPassword => 'New password';

  @override
  String get stepKycId => 'Your ID';

  @override
  String get stepKycSelfie => 'Quick selfie';

  @override
  String get stepKycContact => 'Contact info';

  @override
  String get stepSigninDetails => 'Sign in';

  @override
  String get stepSigninSecurity => 'Security check';

  @override
  String get stepSigninCode => 'Confirm code';

  @override
  String get connectivityLostTitle => 'No internet connection';

  @override
  String get connectivityLostMessage =>
      'Check your network settings and try again.';

  @override
  String get connectivityRestoredTitle => 'You\'re back online';

  @override
  String get connectivityRestoredMessage => 'Connection restored successfully.';
}
