import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

/// The front of a payment card.
///
/// Shared by the add-card form's live preview and the wallet-details page, so a
/// linked card looks exactly like the card the user added rather than a generic
/// wallet tile.
class PaymentCardFace extends StatelessWidget {
  const PaymentCardFace({
    super.key,
    required this.number,
    required this.expiry,
    required this.holder,
    this.brand,
    this.label,
  });

  /// Masked card number, e.g. "•••• •••• •••• 2503".
  final String number;

  /// Expiry as "MM/YY", or a placeholder like "__/__".
  final String expiry;

  /// Cardholder name — rendered uppercase.
  final String holder;

  /// Brand logo (Visa/Mastercard/…) — omitted when unknown.
  final Widget? brand;

  /// Top-left caption; defaults to the localized "DEBIT".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const .symmetric(horizontal: 28, vertical: 19),
      decoration: paymentCardDecoration,
      child: Column(
        mainAxisSize: .max,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                label ?? l10n.walletsDebitLabel,
                style: context.caption.copyWith(
                  fontSize: 15,
                  color: AppColors.white,
                ),
              ),
              SvgPicture.asset(
                'assets/img/bigpay-icon.svg',
                width: 23,
                colorFilter: .mode(AppColors.white, .srcIn),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(
                number,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.header1.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: [
                  Text(
                    'VALID\nTHRU   ',
                    style: context.small.copyWith(
                      fontSize: 6,
                      color: AppColors.cardOverlay,
                    ),
                  ),
                  Text(
                    expiry,
                    style: context.small.copyWith(
                      fontSize: 15,
                      color: AppColors.cardOverlay,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(
                child: Text(
                  holder.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.caption.copyWith(
                    color: AppColors.cardOverlay,
                  ),
                ),
              ),
              ?brand,
            ],
          ),
        ],
      ),
    );
  }
}

/// The card background — a brand gradient over a faint card illustration —
/// shared by [PaymentCardFace] and the add-card form's card back.
final BoxDecoration paymentCardDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(14),
  gradient: LinearGradient(
    colors: [AppColors.primary, AppColors.tint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [
      0.4558, // 45.58%
      1.1780, // 117.8% (values > 1.0 extend the gradient smoothly off-screen)
    ],
  ),
  image: const DecorationImage(
    image: AssetImage('assets/img/card-bg.webp'),
    fit: BoxFit.contain,
    opacity: 0.05,
    alignment: Alignment.center,
    repeat: ImageRepeat.noRepeat,
    filterQuality: FilterQuality.high,
  ),
);
