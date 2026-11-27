import 'package:bigpay/data/models/account/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/ui/components/card/payment_card_face.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/utils/app_state.util.dart';

/// The wallet balance card — used on the dashboard and the wallet details page.
///
/// For the virtual wallet it shows the (toggleable) balance and a Fund Wallet
/// action; for any other wallet it shows the wallet's [title] in place of the
/// balance. [showViewDetails] adds the dashboard-only "View Details" button.
class VirtualWalletCard extends StatefulWidget {
  const VirtualWalletCard({
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

  @override
  State<VirtualWalletCard> createState() => _VirtualWalletCardState();
}

class _VirtualWalletCardState extends State<VirtualWalletCard> {
  /// The balance eye toggle — a State field (not a StatelessWidget field) so
  /// it survives rebuilds (e.g. a dashboard refresh) and is disposed properly.
  final _visible = ValueNotifier(false);

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  /// The balance with any leading currency prefix (GHS/GH/₵) removed, so the
  /// card's own "GHS " prefix isn't doubled.
  String _amount(String? value) {
    final raw = (value ?? '0.00').trim();
    return raw
        .replaceFirst(
          RegExp(r'^(GH[S₵]?|₵)\s*', caseSensitive: false),
          '',
        )
        .trim();
  }

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
            case ActivityTypesConst.fblCollectCategory:
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

  /// Whether this card represents a linked payment card (vs. the virtual
  /// wallet or a bank/mobile-money source).
  bool get _isCard {
    final source = widget.wallet?.sources?.firstOrNull;
    return !widget.isVirtual &&
        '${widget.wallet?.mode} ${source?.mode}'.toUpperCase().contains('CARD');
  }

  double get _height {
    if (widget.isVirtual) return 177;
    return _isCard ? 177 : 131;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCard) return _linkedCard(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.maxFinite,
      height: _height,
      margin: const .all(15),
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        gradient: LinearGradient(
          begin: Alignment(0.84, 0.44), // 293.59° angle
          end: Alignment(-0.84, -0.44),
          colors: AppGradients.walletCard.colors,
          stops: [0.17, 0.5109],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: .topRight,
            child: ClipRRect(
              borderRadius: .circular(12),
              child: SvgPicture.asset(SvgImages.cardCornerIcon),
            ),
          ),
          Padding(
            padding: const .symmetric(vertical: 22, horizontal: 18),
            child: Column(
              mainAxisSize: .max,
              crossAxisAlignment: .start,
              children: [
                Text(
                  widget.isVirtual
                      ? (widget.label ?? l10n.walletsVirtualBalanceLabel)
                      : (widget.title ?? l10n.walletsGenericFallback),
                  style: context.smallDetails.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.isVirtual)
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
                                  style: context.display1.copyWith(
                                    color: AppColors.brightGreen,
                                  ),
                                ),
                                TextSpan(
                                  // Some sources already carry a "GHS"/"GH"
                                  // prefix; strip it so the "GHS " above isn't
                                  // doubled (GHS GHS ...).
                                  text: visible
                                      ? _amount(widget.balance)
                                      : '* *** **',
                                  style: context.display1.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          IconButton.filled(
                            tooltip: visible
                                ? l10n.walletsHideBalanceTooltip
                                : l10n.walletsShowBalanceTooltip,
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
                  // The card description ("VISA •••• 2503 · exp 01/29") is
                  // longer than a balance, so it can exceed the card width at
                  // display1 on a phone and wrap to a second line — which then
                  // overflows the fixed card height. Scale it down to one line
                  // instead of wrapping.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.wallet?.sources?.firstOrNull?.tile ??
                          widget.title ??
                          '',
                      maxLines: 1,
                      style: context.display1.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                const Spacer(),
                if (widget.isVirtual)
                  Row(
                    children: [
                      Expanded(
                        child: FormButton(
                          backgroundColor: AppColors.white11,
                          height: 46,
                          onPressed: () => _fundWallet(context),
                          text: l10n.walletsFundWalletDemo,
                          labelSize: 13,
                          svgIcon: 'assets/img/wallet.svg',
                          iconSize: 15,
                          buttonIconAlignment: .left,
                        ),
                      ),
                      if (widget.showViewDetails) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: FormButton(
                            backgroundColor: AppColors.white11,
                            height: 46,
                            onPressed: widget.onViewDetails ?? () {},
                            text: l10n.walletsViewDetails,
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

  /// The linked-card face — the same card the add-card form previews, filled
  /// with this card's brand, masked number and expiry.
  Widget _linkedCard(BuildContext context) {
    final source = widget.wallet?.sources?.firstOrNull;
    final raw = source?.tile ?? widget.title ?? '';
    final desc = _CardDescriptor.parse(raw);
    return Container(
      width: double.maxFinite,
      height: _height,
      margin: const .all(15),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: .circular(14),
        child: PaymentCardFace(
          number: desc.displayNumber ?? raw,
          expiry: desc.expiry ?? '',
          holder: AppState.currentUser?.user?.name ?? '',
          brand: desc.brandMark(),
        ),
      ),
    );
  }
}

/// Parses the backend's one-line card descriptor — e.g.
/// "VISA •••• 2503 · exp 01/29" — into the parts a card face renders.
/// Anything that doesn't look like a card yields nulls, and the caller falls
/// back to showing the raw line.
class _CardDescriptor {
  const _CardDescriptor({this.brand, this.number, this.expiry});

  final String? brand;
  final String? number;
  final String? expiry;

  static _CardDescriptor parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const _CardDescriptor();

    final expiryMatch = RegExp(r'(\d{1,2})\s*/\s*(\d{2})').firstMatch(text);
    final expiry = expiryMatch == null
        ? null
        : '${expiryMatch.group(1)!.padLeft(2, '0')}/${expiryMatch.group(2)}';

    var rest = text;
    if (expiryMatch != null) rest = rest.substring(0, expiryMatch.start);
    rest = rest
        .replaceAll(RegExp(r'\bexp\b.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'[·•|\-]+\s*$'), '')
        .trim();

    // Brand = the leading alphabetic run (e.g. "VISA", "MASTER CARD").
    final brandMatch = RegExp(
      r'^([A-Za-z]+(?:\s+[A-Za-z]+)?)',
    ).firstMatch(rest);
    final brand = brandMatch?.group(1)?.trim();
    var number = rest;
    if (brandMatch != null) number = rest.substring(brandMatch.end);
    number = number.replaceAll(RegExp(r'^[·•|\-\s]+'), '').trim();

    return _CardDescriptor(
      brand: (brand == null || brand.isEmpty) ? null : brand,
      number: number.isEmpty ? null : number,
      expiry: expiry,
    );
  }

  /// "•••• •••• •••• 2503" when only a 4-digit tail is known, so the face
  /// still reads like a card number; otherwise the number as given.
  String? get displayNumber {
    final n = number;
    if (n == null) return null;
    final digits = n.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 4) return '•••• •••• •••• $digits';
    return n;
  }

  Widget? brandMark() {
    final key = (brand ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (key.contains('VISA')) {
      return SvgPicture.asset(SvgImages.visa, height: 20);
    }
    if (key.contains('MASTER')) {
      return SvgPicture.asset(SvgImages.mastercard, height: 26);
    }
    if (key.contains('AMEX') || key.contains('AMERICANEXPRESS')) {
      return SvgPicture.asset(SvgImages.amex, height: 26);
    }
    if (key.contains('DISCOVER')) {
      return SvgPicture.asset(SvgImages.discover, height: 20);
    }
    return null;
  }
}
