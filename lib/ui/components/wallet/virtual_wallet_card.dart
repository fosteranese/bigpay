import 'package:bigpay/data/models/account/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';

/// The wallet balance card — used on the dashboard and the wallet details page.
///
/// For the virtual wallet it shows the (toggleable) balance and a Fund Wallet
/// action; for any other wallet it shows the wallet's [title] in place of the
/// balance. [showViewDetails] adds the dashboard-only "View Details" button.
class VirtualWalletCard extends StatelessWidget {
  VirtualWalletCard({
    super.key,
    this.label,
    this.balance,
    this.title,
    this.isVirtual = true,
    this.showViewDetails = false,
    this.onViewDetails,
    this.wallet,
  });

  /// Small caption above the balance (virtual wallet).
  final String? label;
  final Account? wallet;

  /// The balance value (virtual wallet).
  final String? balance;

  /// The wallet title, shown in place of the balance for a non-virtual wallet.
  final String? title;

  final bool isVirtual;
  final bool showViewDetails;
  final VoidCallback? onViewDetails;

  final _visible = ValueNotifier(false);

  // Fund Wallet opens the "Top Up" form under the Transfers activity directly,
  // like a most-used service. Kept static since there's no runtime activity to
  // read it from.
  static const _topUpFormId = 'a454e670-6851-4085-a139-1da5868c531e';
  static const _topUpActivityId = '713754C2-C287-4777-9CC7-FE4D0133DEC3';
  static const _topUpActivityType = ActivityTypesConst.fblOnline;

  /// Fetches the Top Up form and hands the result to the dashboard's central
  /// listener, which jumps to the service form.
  void _fundWallet(BuildContext context) {
    GetServiceFormDataAction.activityDatum = ActivityDatum(
      activity: Activity(
        activityId: _topUpActivityId,
        activityType: _topUpActivityType,
        activityName: 'Fund Wallet',
      ),
    );
    GetServiceFormDataAction.event = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceFormDataAction(
        payload: GetServiceFormDataActionPayload(
          formId: _topUpFormId,
          insId: _topUpFormId,
        ),
        endpointFunc: () {
          switch (_topUpActivityType) {
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

  double get _height {
    return isVirtual ? 177 : 177 - 46;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: _height,
      margin: const .all(15),
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        gradient: LinearGradient(
          begin: Alignment(0.84, 0.44), // 293.59° angle
          end: Alignment(-0.84, -0.44),
          colors: [Color(0xFF221E55), Color(0xFF20428C)],
          stops: [0.17, 0.5109],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: .topRight,
            child: ClipRRect(
              borderRadius: .circular(12),
              child: SvgPicture.asset('assets/img/card-corner-icon.svg'),
            ),
          ),
          Padding(
            padding: const .symmetric(vertical: 22, horizontal: 18),
            child: Column(
              mainAxisSize: .max,
              crossAxisAlignment: .start,
              children: [
                Text(
                  isVirtual
                      ? (label ?? 'Virtual Wallet Balance')
                      : (title ?? 'Wallet'),
                  style: AppTypography.smallDetails.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (isVirtual)
                  ValueListenableBuilder(
                    valueListenable: _visible,
                    builder: (context, visible, child) {
                      return Row(
                        mainAxisSize: .max,
                        mainAxisAlignment: .start,
                        crossAxisAlignment: .center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'GHS ',
                                  style: AppTypography.display1.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                TextSpan(
                                  text: visible
                                      ? balance ?? '0.00'
                                      : '* *** **',
                                  style: AppTypography.display1,
                                ),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            tooltip: visible ? 'Hide balance' : 'Show balance',
                            style: IconButton.styleFrom(
                              alignment: .center,
                              backgroundColor: AppColors.white11,
                              fixedSize: Size(44, 44),
                            ),
                            onPressed: () => _visible.value = !_visible.value,
                            icon: SvgPicture.asset(
                              visible ? SvgImages.invisible : SvgImages.visible,
                              colorFilter: .mode(AppColors.white, .srcIn),
                              width: 24,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Text(
                    wallet?.sources?.first.tile ?? title ?? '',
                    style: AppTypography.display1.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                const Spacer(),
                if (isVirtual)
                  Row(
                    children: [
                      Expanded(
                        child: FormButton(
                          backgroundColor: AppColors.white11,
                          height: 46,
                          onPressed: () => _fundWallet(context),
                          text: 'Fund Wallet',
                          labelSize: 13,
                          svgIcon: 'assets/img/wallet.svg',
                          iconSize: 15,
                          buttonIconAlignment: .left,
                        ),
                      ),
                      if (showViewDetails) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: FormButton(
                            backgroundColor: AppColors.white11,
                            height: 46,
                            onPressed: onViewDetails ?? () {},
                            text: 'View Details',
                            labelSize: 13,
                            svgIcon: 'assets/img/trending-up.svg',
                            iconSize: 15,
                            buttonIconAlignment: .left,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
