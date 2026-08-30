import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets/add-card',
  );

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();

  final _numberFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _expiryFocus = FocusNode();

  /// Drives the front/back flip — forward while the CVV field has focus
  /// (real cards print the CVV on the back, next to the signature strip),
  /// reverse the moment focus leaves for any reason (submitted, tapped
  /// away, backgrounded).
  late final AnimationController _flipController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _cvvFocus.addListener(_onCvvFocusChanged);
  }

  void _onCvvFocusChanged() {
    if (_cvvFocus.hasFocus) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _cvvFocus.removeListener(_onCvvFocusChanged);
    _flipController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    _numberFocus.dispose();
    _cvvFocus.dispose();
    _expiryFocus.dispose();
    super.dispose();
  }

  String get _rawNumber => _numberController.text.replaceAll(' ', '');

  _CardBrand get _brand => _CardBrand.detect(_rawNumber);

  /// MM part of the expiry, or null if what's typed so far isn't a
  /// plausible month — used both for validation and left un-flagged (no
  /// error border) until there are enough digits to actually judge.
  int? get _expiryMonth {
    final digits = _expiryController.text.replaceAll('/', '');
    if (digits.length < 2) return null;
    return int.tryParse(digits.substring(0, 2));
  }

  bool get _canSave {
    final month = _expiryMonth;
    return _nameController.text.trim().isNotEmpty &&
        _rawNumber.length == _brand.numberLength &&
        _cvvController.text.length >= 3 &&
        _expiryController.text.length == 5 &&
        month != null &&
        month >= 1 &&
        month <= 12;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      miniTitle: l10n.walletsAddCardTitle,
      bottomSize: 98 + 61 + 56,
      subtitleWidget: SizedBox(
        height: 189,
        width: double.maxFinite,
        child: AnimatedBuilder(
          animation: _flipController,
          builder: (context, child) {
            // 0 -> pi over the animation; past the halfway point we're
            // looking at the back of the card, so swap content and
            // subtract pi from the remaining rotation — otherwise the back
            // would keep turning through to pi and render mirror-flipped
            // instead of settling face-on.
            final angle = _flipController.value * 3.14159265;
            final isBack = angle > 3.14159265 / 2;
            return Transform(
              alignment: .center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(isBack ? angle - 3.14159265 : angle),
              child: isBack ? _buildCardBack(context) : _buildCardFront(context),
            );
          },
        ),
      ),

      bottomNav: FormButton(
        onPressed: () {},
        enabled: _canSave,
        text: l10n.commonSave,
      ),
      child: Column(
        children: [
          FormInput(
            controller: _nameController,
            label: l10n.walletsCardHolderNameLabel,
            textInputAction: .next,
            onChanged: (_) => setState(() {}),
            next: (_) => _numberFocus.requestFocus(),
          ),
          const SizedBox(height: 10),
          FormInput(
            controller: _numberController,
            label: l10n.walletsCardNumberLabel,
            focusNode: _numberFocus,
            keyboardType: .number,
            inputFormatters: [_CardNumberFormatter()],
            onChanged: (_) => setState(() {}),
            next: (_) => _cvvFocus.requestFocus(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormInput(
                  controller: _cvvController,
                  label: l10n.walletsCvvLabel,
                  focusNode: _cvvFocus,
                  keyboardType: .number,
                  isPassword: true,
                  // FormInput passes this straight through as
                  // TextFormField's maxLines — left at its null default
                  // that combines with obscureText: true to trip
                  // TextFormField's own "obscured fields must be single
                  // line" assertion.
                  maxLines: 1,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {}),
                  next: (_) => _expiryFocus.requestFocus(),
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: FormInput(
                  controller: _expiryController,
                  label: l10n.walletsExpiryDateLabel,
                  focusNode: _expiryFocus,
                  keyboardType: .number,
                  placeholder: 'MM/YY',
                  inputFormatters: [_ExpiryDateFormatter()],
                  onChanged: (_) => setState(() {}),
                  next: (_) => _expiryFocus.unfocus(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    borderRadius: .circular(14),
    gradient: LinearGradient(
      colors: [
        AppColors.primary,
        AppColors.tint,
      ],
      begin: .topLeft,
      end: .bottomRight,
      stops: [
        0.4558, // 45.58%
        1.1780, // 117.8% (Values > 1.0 extend the gradient smoothly off-screen)
      ],
    ),
    image: DecorationImage(
      image: AssetImage('assets/img/card-bg.png'),
      fit: .contain,
      opacity: 0.05,
      alignment: .center,
      repeat: .noRepeat,
      filterQuality: .high,
    ),
  );

  Widget _buildCardFront(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: .symmetric(horizontal: 28, vertical: 19),
      decoration: _cardDecoration,
      child: Column(
        mainAxisSize: .max,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                l10n.walletsDebitLabel,
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
                _numberController.text.isEmpty
                    ? '••••    ••••    ••••    ••••'
                    : _numberController.text,
                textAlign: .left,
                style: context.header1.copyWith(
                  color: AppColors.white,
                ),
              ),

              Row(
                mainAxisSize: .min,
                mainAxisAlignment: .start,
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
                    _expiryController.text.isEmpty
                        ? '__/__'
                        : _expiryController.text,
                    style: context.small.copyWith(
                      fontSize: 15,
                      color: AppColors.cardOverlay,
                      textBaseline: .alphabetic,
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
                  _nameController.text.trim().isEmpty
                      ? l10n.walletsCardNamePlaceholder
                      : _nameController.text.trim().toUpperCase(),
                  overflow: .ellipsis,
                  style: context.caption.copyWith(
                    color: AppColors.cardOverlay,
                  ),
                ),
              ),
              _brand.mark(context),
            ],
          ),
        ],
      ),
    );
  }

  /// The back — a magnetic stripe, then a signature strip ending in the
  /// CVV box, matching where a real card actually prints it. Rendered only
  /// while [_flipController] has this face pointed at the viewer; the
  /// content itself doesn't need to know about the flip.
  Widget _buildCardBack(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: _cardDecoration,
      child: Column(
        mainAxisSize: .max,
        crossAxisAlignment: .stretch,
        children: [
          const SizedBox(height: 16),
          Container(height: 32, color: AppColors.black),
          const SizedBox(height: 16),
          Padding(
            padding: const .symmetric(horizontal: 28),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: .centerRight,
                    padding: const .symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardOverlay,
                      borderRadius: .circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 32,
                  width: 52,
                  alignment: .center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: .circular(4),
                  ),
                  // Masked, not the actual digits — this is a live preview
                  // on screen, not the confirmation slip a physical card
                  // ships with; showing it in clear text here would defeat
                  // the point of the field being obscured in the form.
                  child: Text(
                    '•' *
                        (_cvvController.text.isEmpty
                            ? 3
                            : _cvvController.text.length),
                    style: context.caption.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const .symmetric(horizontal: 28),
            child: Text(
              l10n.walletsCvvLabel,
              style: context.small.copyWith(
                fontSize: 10,
                color: AppColors.cardOverlay,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const .symmetric(horizontal: 28, vertical: 8),
            child: Row(
              mainAxisAlignment: .end,
              children: [_brand.mark(context)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Identified from the leading digits (the IIN/BIN ranges each network
/// registers), same ranges Stripe/most card SDKs use. Only the networks
/// this form's fields already assume (a 16-digit PAN, except Amex's 15) are
/// distinguished from "unknown" — a longer tail (Diners, JCB, UnionPay, …)
/// would need those fields to accommodate different lengths/CVV sizes too.
///
/// [mark] renders each network's own logo (assets/img/{visa,mastercard,
/// amex,discover}.svg).
enum _CardBrand {
  visa(16),
  mastercard(16),
  amex(15),
  discover(16),
  unknown(16);

  const _CardBrand(this.numberLength);

  /// Expected PAN length for this network — [_AddCardPageState._canSave]
  /// validates against this instead of a hardcoded 16, so a detected Amex
  /// number isn't held to Visa/Mastercard's length.
  final int numberLength;

  static _CardBrand detect(String digits) {
    if (digits.isEmpty) return _CardBrand.unknown;

    if (digits.startsWith('4')) return _CardBrand.visa;

    final firstTwo = int.tryParse(
      digits.length >= 2 ? digits.substring(0, 2) : '',
    );
    if (firstTwo == 34 || firstTwo == 37) {
      return _CardBrand.amex;
    }
    if (firstTwo != null && firstTwo >= 51 && firstTwo <= 55) {
      return _CardBrand.mastercard;
    }

    final firstFour = int.tryParse(
      digits.length >= 4 ? digits.substring(0, 4) : '',
    );
    if (firstFour != null && firstFour >= 2221 && firstFour <= 2720) {
      return _CardBrand.mastercard;
    }
    if (firstFour == 6011) return _CardBrand.discover;

    final firstThree = int.tryParse(
      digits.length >= 3 ? digits.substring(0, 3) : '',
    );
    if (firstThree != null && firstThree >= 644 && firstThree <= 649) {
      return _CardBrand.discover;
    }
    if (firstTwo == 65) return _CardBrand.discover;

    return _CardBrand.unknown;
  }

  Widget mark(BuildContext context) {
    switch (this) {
      case _CardBrand.visa:
        return SvgPicture.asset(SvgImages.visa, height: 24);
      case _CardBrand.mastercard:
        return SvgPicture.asset(SvgImages.mastercard, height: 32);
      case _CardBrand.amex:
        return SvgPicture.asset(SvgImages.amex, height: 32);
      case _CardBrand.discover:
        return SvgPicture.asset(SvgImages.discover, height: 24);
      case _CardBrand.unknown:
        return const SizedBox.shrink();
    }
  }
}

/// Groups digits into 4s as they're typed (`4111 1111 1111 1111`), capped at
/// 16 digits. Always collapses the cursor to the end — simple, and the only
/// place that matters (typing forward) works naturally; editing mid-number
/// isn't worth the extra complexity for a field this short-lived.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Inserts the `/` after the month (`MM/YY`), capped at 4 digits.
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
