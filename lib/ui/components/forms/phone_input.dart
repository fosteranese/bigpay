import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';
import 'package:bigpay/utils/app_state.util.dart';

/// Owns the pairing of a selected [country] and the digits typed in that
/// country's national format, and derives the international value other
/// code actually needs to send — e.g. `233243505598` for a Ghana number
/// typed as `0243505598`.
class PhoneNumberController extends ChangeNotifier {
  PhoneNumberController({CountryWithPhoneCode? country, String national = ''})
    : _country = country ?? AppState.currentCountry,
      text = TextEditingController(text: national);

  final TextEditingController text;

  CountryWithPhoneCode _country;
  CountryWithPhoneCode get country => _country;
  set country(CountryWithPhoneCode value) {
    if (value.countryCode == _country.countryCode) return;
    _country = value;
    // A prior country's mask (spacing/grouping) doesn't necessarily fit the
    // new one — start the digits fresh rather than show a mismatched mask.
    text.clear();
    notifyListeners();
  }

  static final _nonDigits = RegExp(r'\D');

  String get _digits => text.text.replaceAll(_nonDigits, '');

  /// The typed digits with a single leading trunk `0` removed, if present —
  /// the part that combines with the country's dial code to form the
  /// international number.
  String get _significant =>
      _digits.startsWith('0') ? _digits.substring(1) : _digits;

  /// E.g. `233243505598` — dial code + national significant digits, no `+`
  /// and no separators. What every `phoneNumber` payload field should hold.
  String get international => '${_country.phoneCode}$_significant';

  /// How many digits the selected country's national mobile number expects,
  /// derived from its mask — lets a phone number be checked for completeness
  /// without a hand-maintained per-country validation table.
  int get _expectedDigitCount => _country
      .getPhoneMask(
        format: PhoneNumberFormat.national,
        type: PhoneNumberType.mobile,
        removeCountryCodeFromMask: true,
      )
      .replaceAll(_nonDigits, '')
      .length;

  bool get isValid =>
      _digits.isNotEmpty && _digits.length == _expectedDigitCount;

  /// A [FormInput.validator] bound to this controller's currently selected
  /// country — empty stays valid (required-ness, if any, is enforced
  /// elsewhere), a partial/overlong number reports [message].
  String? Function(String?) validator(String message) {
    return (String? _) {
      if (text.text.trim().isEmpty) return null;
      return isValid ? null : message;
    };
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}

/// A phone number field with a tappable country/dial-code prefix. The user
/// types in their country's national format (e.g. `024 350 5598`); the
/// international value other code should actually send lives on
/// [controller] (see [PhoneNumberController.international]).
class PhoneNumberInput extends StatefulWidget {
  const PhoneNumberInput({
    super.key,
    required this.controller,
    this.label,
    this.focusNode,
    this.next,
    this.onChanged,
    this.validator,
    this.textInputAction,
  });

  final PhoneNumberController controller;
  final String? label;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;
  final TextInputAction? textInputAction;

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCountryChanged);
  }

  @override
  void didUpdateWidget(PhoneNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCountryChanged);
      widget.controller.addListener(_onCountryChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCountryChanged);
    super.dispose();
  }

  void _onCountryChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final country = widget.controller.country;
    return FormInput(
      label: widget.label,
      placeholder: country.exampleNumberMobileNational,
      controller: widget.controller.text,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      next: widget.next,
      validator: widget.validator,
      onChanged: widget.onChanged,
      inputFormatters: [
        LibPhonenumberTextFormatter(
          country: country,
          phoneNumberFormat: PhoneNumberFormat.national,
        ),
      ],
      prefix: _CountryButton(
        country: country,
        onTap: _openCountryPicker,
      ),
    );
  }

  void _openCountryPicker() {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final cap = contentCapWidth(context);
    final searchController = TextEditingController();
    var filtered = AppState.countries;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useRootNavigator: true,
      constraints: cap == double.infinity
          ? null
          : BoxConstraints(maxWidth: cap),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          void onSearch(String query) {
            final q = query.trim().toLowerCase();
            setSheetState(() {
              filtered = q.isEmpty
                  ? AppState.countries
                  : AppState.countries
                        .where(
                          (c) =>
                              (c.countryName ?? '').toLowerCase().contains(q) ||
                              c.phoneCode.contains(q),
                        )
                        .toList();
            });
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: sheetContext.cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.commonSelect, style: sheetContext.header1),
                        IconButton.filled(
                          tooltip: l10n.commonClose,
                          style: IconButton.styleFrom(
                            alignment: Alignment.center,
                            backgroundColor: sheetContext.divider,
                            fixedSize: const Size(44, 44),
                          ),
                          onPressed: () => sheetContext.pop(),
                          icon: Icon(
                            Icons.close,
                            size: 17,
                            color: sheetContext.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 10),
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: l10n.commonSearch,
                            hintStyle: sheetContext.caption,
                            prefixIcon: const Icon(Icons.search),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: sheetContext.border,
                                style: BorderStyle.solid,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: sheetContext.divider,
                          ),
                          onChanged: onSearch,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? _emptyState(
                              sheetContext,
                              message: searchController.text.isEmpty
                                  ? l10n.commonNoOptionsAvailable
                                  : l10n.commonNoResultsFound,
                              icon: searchController.text.isEmpty
                                  ? Icons.inbox_outlined
                                  : Icons.search_off_outlined,
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => _countryTile(
                                sheetContext,
                                filtered[i],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required String message,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: context.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            style: context.smallDetails,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _countryTile(BuildContext context, CountryWithPhoneCode country) {
    final selected =
        country.countryCode == widget.controller.country.countryCode;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: () {
            widget.controller.country = country;
            Navigator.pop(context);
          },
          selected: selected,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: Text(
            countryFlagEmoji(country.countryCode),
            style: const TextStyle(fontSize: 22),
          ),
          title: Text(
            country.countryName ?? country.countryCode,
            style: context.formLabels,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('+${country.phoneCode}', style: context.caption),
              const SizedBox(width: 8),
              FormRadioButton(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onTap});

  final CountryWithPhoneCode country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              countryFlagEmoji(country.countryCode),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              '+${country.phoneCode}',
              style: context.formLabels.copyWith(color: context.textPrimary),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_outlined,
              size: 16,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts a two-letter ISO 3166-1 country code (e.g. `GH`) to its flag
/// emoji by mapping each letter to a Unicode regional indicator symbol.
String countryFlagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return '🏳️';
  const base = 0x1F1E6;
  const aCode = 0x41;
  return String.fromCharCodes(
    code.codeUnits.map((c) => base + (c - aCode)),
  );
}
