import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/general_flow/form_verification_response.dart';
import 'package:bigpay/data/models/general_flow/general_flow_category.dart';
import 'package:bigpay/data/models/general_flow/general_flow_form_data.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/models/actions/services/process_request_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/process_flow/done.pg.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/message.util.dart';

/// Confirmation screen shown after a form is verified: it renders the
/// verification's `previewData` (amount, charges, total, entered fields).
///
/// Continue processes the request — collecting an OTP first when the
/// verification says a second factor is required.
class SummaryPage extends StatefulWidget {
  const SummaryPage({
    super.key,
    this.verification,
    this.formData,
    this.activityDatum,
    this.category,
  });

  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services/summary',
  );

  /// The `verifyForm` result. Nullable so a direct hit on the route degrades
  /// gracefully.
  final FormVerificationResponse? verification;
  final GeneralFlowFormData? formData;
  final ActivityDatum? activityDatum;
  final GeneralFlowCategory? category;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  ExecuteProcessEvent? _processEvent;

  void _continue() {
    if (widget.verification?.requireSecondFactor == true) {
      _promptOtp();
      return;
    }
    _process();
  }

  void _promptOtp() {
    AppModal.showBottomModal(
      context,
      label: 'Enter OTP',
      padding: const .all(20),
      children: [
        Text(
          'Enter the code sent to you to authorise this transaction.',
          style: AppTypography.smallDetails.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 20),
        FormOtpInput(
          count: 6,
          onCompleted: (otp) {
            Navigator.pop(context);
            _process(otp: otp);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _process({String? otp}) {
    final data = widget.verification?.formData ?? const {};
    _processEvent = context.dispatchProcess(
      ProcessRequestAction(
        payload: ProcessRequestActionPayload(
          activityId: widget.activityDatum?.activity?.activityId,
          formId: widget.formData?.form?.formId,
          formData: data,
          paymentMode: (data['SourceAccount'] as String?) ?? '',
          otp: otp,
        ),
        endpointFunc: _processEndpoint,
      ),
    );
  }

  String _processEndpoint() {
    switch (widget.formData?.form?.activityType) {
      case ActivityTypesConst.fblCollect:
        return '/FBLCollect/processRequest';
      case ActivityTypesConst.quickFlow:
      case ActivityTypesConst.quickFlowAlt:
        return '/QuickFlow/processRequest';
      case ActivityTypesConst.fblOnline:
      case ActivityTypesConst.enquiry:
      default:
        return '/FBLOnline/processRequest';
    }
  }

  /// (title, value) rows: the service name followed by the server's preview
  /// rows. Rows without a value are dropped.
  List<(String, String)> get _rows {
    final rows = <(String, String)>[];

    final service =
        widget.formData?.form?.formName ??
        widget.activityDatum?.activity?.activityName ??
        '';
    if (service.isNotEmpty) {
      rows.add(('Service', service));
    }

    for (final item in widget.verification?.previewData ?? const []) {
      final key = item.key;
      final value = item.value;
      if (key == null || value == null || value.isEmpty) continue;
      rows.add((key, value));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return ProcessListener<RequestResponse>(
      event: () => _processEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.isSuccessful) {
          _processEvent = null;
          AppRouter.router.push(
            DonePage.route.path,
            extra: snapshot.data,
          );
          return;
        }

        if (snapshot.hasError) {
          _processEvent = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
        subtitleWidget: Column(
          children: [
            Text(
              'Transaction Summary',
              textAlign: .center,
              style: AppTypography.display2,
            ),
            const SizedBox(height: 10),
            Text(
              'Kindly confirm the transaction details before you proceed',
              textAlign: .center,
              style: AppTypography.smallDetails,
            ),
          ],
        ),
        bottomNav: FormButton(
          onPressed: _continue,
          text: 'Continue',
        ),
        child: Container(
          padding: .all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: .circular(12),
          ),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              for (final (index, (title, value)) in rows.indexed) ...[
                TransactionDetailsItem(title: title, value: value),
                if (index != rows.length - 1)
                  Divider(color: AppColors.offWhite),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
