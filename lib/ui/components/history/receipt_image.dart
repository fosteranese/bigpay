import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';

/// The branded, shareable transaction receipt — rendered off-screen and
/// captured to a PNG for sharing. Fixed light colours so the shared image looks
/// the same regardless of the in-app light/dark theme.
class ReceiptImage extends StatelessWidget {
  const ReceiptImage({super.key, required this.receipt});

  final RequestResponse receipt;

  static const _headerBg = Color(0xFFECEDF1);
  static const _cardBg = Color(0xFFF2F3F5);
  static const _ink = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF6E6E7A);
  static const _divider = Color(0xFFD7D9E0);

  // Static brand contact line shown at the foot of every receipt.
  static const _footer =
      "We're here to help! Call us at 0302 666 331, use our Toll-Free line at "
      '0800-100880 (Telecel only), or dial 0302633988. You can also email '
      'info@mybigpaybank.com or visit www.bigpay.com.gh.';

  /// (label, value, bold) rows: the service, then the server's preview rows.
  List<(String, String, bool)> get _rows {
    final rows = <(String, String, bool)>[];
    final service = receipt.formName ?? receipt.activityName ?? '';
    if (service.isNotEmpty) rows.add(('Service', service, true));
    for (final item in receipt.previewData) {
      final key = item.key;
      final value = item.value;
      if (key == null || value == null || value.isEmpty) continue;
      rows.add((key, value, key.toLowerCase().contains('total')));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final amountIndex = rows.indexWhere(
      (r) => r.$1.toLowerCase().contains('amount'),
    );

    return Container(
      width: 575,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        children: [
          // Header bar: logo + RECEIPT.
          Container(
            color: _headerBg,
            padding: const .symmetric(horizontal: 28, vertical: 28),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                SvgPicture.asset(SvgImages.icon, height: 34),
                const Text(
                  'RECEIPT',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB7BAC4),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const .fromLTRB(28, 28, 28, 0),
            child: Align(
              alignment: .centerRight,
              child: Text(
                receipt.receiptDateTime ?? receipt.receiptDate ?? '',
                style: const TextStyle(fontSize: 15, color: _ink),
              ),
            ),
          ),
          // Details card.
          Container(
            margin: const .fromLTRB(20, 20, 20, 0),
            padding: const .symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: .circular(10),
            ),
            child: Column(
              mainAxisSize: .min,
              children: [
                for (final (index, (label, value, bold)) in rows.indexed) ...[
                  if (index == amountIndex && amountIndex > 0) ...[
                    const SizedBox(height: 6),
                    const Divider(color: _divider, height: 1),
                    const SizedBox(height: 10),
                  ],
                  _row(label, value, bold: bold),
                ],
              ],
            ),
          ),
          Padding(
            padding: const .fromLTRB(28, 48, 28, 36),
            child: Text(
              _footer,
              textAlign: .center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {required bool bold}) {
    final weight = bold ? FontWeight.w700 : FontWeight.w400;
    return Padding(
      padding: const .symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: _muted, fontWeight: weight),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: .right,
              style: TextStyle(fontSize: 15, color: _ink, fontWeight: weight),
            ),
          ),
        ],
      ),
    );
  }
}
