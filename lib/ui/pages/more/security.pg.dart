import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/models/actions/security/verify_pin_action.dart';
import 'package:bigpay/models/actions/services/get_service_categories_action.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/more.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service_form.pg.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/authentication.util.dart';
import 'package:bigpay/utils/biometric.util.dart';
import 'package:bigpay/utils/message.util.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more/security',
  );

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  /// The fixed security activity — the same one umb's security page loads its
  /// forms (change PIN, password, secure phrase, …) from.
  static const _securityActivityId = 'B534D7FC-5365-4CBE-9CB2-D2AE36C2C173';

  /// Loads the security category's forms.
  ExecuteProcessEvent? _categoriesEvent;

  /// The in-flight fetch of a tapped form, correlated to navigate to the form.
  ExecuteProcessEvent? _formEvent;

  GeneralFlowCategory? _category;

  // Biometric settings.
  bool _loginEnabled = false;
  bool _transactionEnabled = false;
  ExecuteProcessEvent? _loginPinEvent;
  ExecuteProcessEvent? _transactionPinEvent;

  /// The PIN captured from the prompt and whether the pending toggle is turning
  /// the setting on — read once the backend verifies the PIN.
  String? _pendingPin;
  bool _pendingEnable = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final login = await BiometricUtil.isLoginEnabled;
    final transaction = await BiometricUtil.isTransactionEnabled;
    if (!mounted) return;
    setState(() {
      _loginEnabled = login;
      _transactionEnabled = transaction;
    });
  }

  void _loadCategories() {
    _categoriesEvent = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceCategoriesAction(
        endpointFunc: () => '/FBLOnline/categories/$_securityActivityId',
      ),
    );
  }

  /// Pull-to-refresh: re-loads the security forms and re-reads the on-device
  /// biometric settings, holding the spinner until the forms land.
  Future<void> _onRefresh() async {
    setState(_loadCategories);
    _loadBiometricSettings();
    await context.awaitProcess(_categoriesEvent);
  }

  // --- Security forms -------------------------------------------------------

  /// Fetches a tapped security form and jumps to it — the same direct-to-form
  /// path used by the dashboard's most-used services.
  void _openForm(GeneralFlowForm form) {
    _formEvent = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceFormDataAction(
        payload: GetServiceFormDataActionPayload(
          formId: form.formId,
          insId: form.formId,
        ),
        endpointFunc: () {
          switch (form.activityType) {
            case ActivityTypesConst.fblCollect:
              return '/FBLCollect/formsDataByInsId';
            case ActivityTypesConst.quickFlow:
            case ActivityTypesConst.quickFlowAlt:
              return '/QuickFlow/formDataByFormId';
            case ActivityTypesConst.fblOnline:
            case ActivityTypesConst.enquiry:
            default:
              return '/FBLOnline/formDataByFormId';
          }
        },
      ),
    );
  }

  void _handleFormData(BuildContext context, ProcessSnapshot snapshot) {
    if (snapshot.isLoading && !snapshot.isSilent && !snapshot.isCached) {
      MessageUtil.displayLoading(context);
      return;
    } else if (!snapshot.isSilent && !snapshot.isCached) {
      MessageUtil.close(context);
    }

    if (snapshot.hasData && !(snapshot.isSilent && !snapshot.isCached)) {
      final formData = snapshot.data as GeneralFlowFormData?;
      if (!snapshot.isSilent &&
          !snapshot.isCached &&
          (formData?.fieldsDatum?.isEmpty ?? true)) {
        MessageUtil.displayErrorDialog(
          context,
          title: 'Service Unavailable',
          message: 'This service is currently not available',
        );
        return;
      }

      AppRouter.router.push(
        ServiceFormPage.route.path,
        extra: {
          'activityDatum': ActivityDatum(
            activity: Activity(activityId: _securityActivityId),
          ),
          'category': _category ?? const GeneralFlowCategory(),
          'formData': formData,
        },
      );
      return;
    }

    if (snapshot.hasError) {
      MessageUtil.displayErrorDialog(
        context,
        message: snapshot.error!.message,
      );
    }
  }

  // --- Biometric toggles ----------------------------------------------------

  /// Turning a biometric setting on first confirms the device biometric, then
  /// captures and verifies the PIN (stored for later replay). Turning it off
  /// just re-verifies the PIN.
  Future<void> _toggle({required bool isLogin, required bool enabling}) async {
    if (enabling) {
      final result = await BiometricUtil.authenticate(
        'Confirm to enable biometric access',
      );
      if (!mounted) return;

      // Only block when the device genuinely has no biometrics enrolled — a
      // cancel/mismatch just aborts silently.
      if (result == BiometricResult.unavailable) {
        MessageUtil.displayErrorDialog(
          context,
          title: 'Biometrics Unavailable',
          message: 'Set up Face ID or a fingerprint on your device first.',
        );
        return;
      }
      if (result != BiometricResult.success) return;
    }

    _pendingEnable = enabling;
    AuthenticationUtil.pin(
      data: const {
        'fieldLength': 6,
        'tooltip': 'Enter Security PIN',
        'description': 'Confirm your PIN to update biometric settings.',
      },
      onSuccess: (pin) {
        // Dismiss the PIN dialog, then verify with the backend.
        AppRouter.router.pop();
        _pendingPin = pin;
        final event = context.dispatchProcess(
          VerifyPinAction(payload: VerifyPinActionPayload(pin: pin)),
        );
        setState(() {
          if (isLogin) {
            _loginPinEvent = event;
          } else {
            _transactionPinEvent = event;
          }
        });
      },
    );
  }

  void _onPinVerified(
    BuildContext context,
    ProcessSnapshot<bool> snapshot, {
    required bool isLogin,
  }) {
    if (snapshot.isLoading) {
      MessageUtil.displayLoading(context);
      return;
    }
    MessageUtil.close(context);

    if (snapshot.isSuccessful) {
      final enable = _pendingEnable;
      final pin = _pendingPin;
      _pendingPin = null;
      _persistBiometric(isLogin: isLogin, enable: enable, pin: pin);
      return;
    }

    if (snapshot.hasError) {
      _pendingPin = null;
      MessageUtil.displayErrorDialog(
        context,
        message: snapshot.error!.message,
      );
    }
  }

  Future<void> _persistBiometric({
    required bool isLogin,
    required bool enable,
    required String? pin,
  }) async {
    if (isLogin) {
      await BiometricUtil.setLoginEnabled(enable);
    } else {
      await BiometricUtil.setTransactionEnabled(enable);
    }

    // Post-toggle state — the `_loginEnabled`/`_transactionEnabled` fields
    // aren't updated until the setState below, so compute the new values here.
    final loginEnabled = isLogin ? enable : _loginEnabled;
    final transactionEnabled = isLogin ? _transactionEnabled : enable;

    if (enable && pin != null) {
      await BiometricUtil.savePin(pin);
    } else if (!loginEnabled && !transactionEnabled) {
      // Both settings are now off — drop the stored PIN.
      await BiometricUtil.savePin('');
    }

    if (!mounted) return;
    setState(() {
      if (isLogin) {
        _loginEnabled = enable;
      } else {
        _transactionEnabled = enable;
      }
    });
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<GeneralFlowFormData>(
          event: () => _formEvent,
          listener: _handleFormData,
        ),
        ProcessListenerConfig<bool>(
          event: () => _loginPinEvent,
          listener: (context, snapshot) =>
              _onPinVerified(context, snapshot, isLogin: true),
        ),
        ProcessListenerConfig<bool>(
          event: () => _transactionPinEvent,
          listener: (context, snapshot) =>
              _onPinVerified(context, snapshot, isLogin: false),
        ),
      ],
      child: MainLayout(
        bottomSize: 60,
        title: 'Security',
        onRefresh: _onRefresh,
        child: ProcessConsumer<GeneralFlowCategory>(
          event: () => _categoriesEvent,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _category = snapshot.data);
            }
          },
          builder: (context, snapshot) {
            final forms = _category?.forms ?? const [];
            final loading = _category == null && snapshot.isLoading;

            return Column(
              children: [
                if (loading)
                  const Padding(
                    padding: .symmetric(vertical: 30),
                    child: CircularProgressIndicator(),
                  )
                else
                  for (final form in forms) _buildFormItem(form),
                Divider(
                  color: context.divider,
                  thickness: 4,
                  indent: 10,
                  endIndent: 10,
                  height: 30,
                ),
                _biometricSwitch(
                  title: 'Sign in with Biometrics',
                  value: _loginEnabled,
                  onChanged: (value) => _toggle(isLogin: true, enabling: value),
                ),
                _biometricSwitch(
                  title: 'Transact with Biometrics',
                  value: _transactionEnabled,
                  onChanged: (value) =>
                      _toggle(isLogin: false, enabling: value),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormItem(GeneralFlowForm form) {
    return ProfileItem(
      onPressed: () => _openForm(form),
      title: form.formName ?? '',
      icon: Icons.fingerprint,
      iconUrl:
          '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${form.icon}',
    );
  }

  Widget _biometricSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ProfileItem(
      title: title,
      icon: Icons.fingerprint,
      trailing: SizedBox(
        height: 30,
        width: 49,
        child: FittedBox(
          child: Switch(
            value: value,
            padding: .zero,
            materialTapTargetSize: .shrinkWrap,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
