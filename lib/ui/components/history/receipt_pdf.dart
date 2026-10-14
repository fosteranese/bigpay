import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';

/// Builds the branded transaction receipt as a single-page PDF.
///
/// The layout mirrors [ReceiptImage] (the same header bar, details card and
/// footer) so the shared file looks like the on-screen receipt, but rendered
/// natively by the `pdf` package — no off-screen widget capture, so it cannot
/// fall back to plain text. Fixed light colours keep it theme-independent, and
/// the built-in Helvetica fonts need no network font download.
class ReceiptPdf {
  ReceiptPdf._();

  static const _width = 575.0;

  static const _headerBg = PdfColor.fromInt(0xFFECEDF1);
  static const _cardBg = PdfColor.fromInt(0xFFF2F3F5);
  static const _ink = PdfColor.fromInt(0xFF1A1A2E);
  static const _muted = PdfColor.fromInt(0xFF6E6E7A);
  static const _divider = PdfColor.fromInt(0xFFD7D9E0);
  static const _receiptWord = PdfColor.fromInt(0xFFB7BAC4);

  // Static brand contact line shown at the foot of every receipt.
  static const _footer =
      "We're here to help! Call us at 0302 666 331, use our Toll-Free line at "
      '0800-100880 (Telecel only), or dial 0302633988. You can also email '
      'info@mybigpaybank.com or visit www.bigpay.com.gh.';

  /// Generates the receipt PDF bytes for [receipt].
  static Future<Uint8List> build(RequestResponse receipt) async {
    final rows = _rows(receipt);
    final amountIndex = rows.indexWhere(
      (r) => r.$1.toLowerCase().contains('amount'),
    );

    // Section heights, matching the paddings/sizes used by [ReceiptImage].
    final headerHeight = 28.0 + 34.0 + 28.0; // vertical padding + logo
    final dateHeight = 28.0 + 22.0;
    final rowHeight = 36.0; // vertical padding 8 + ~20 text
    final dividerBlock = 17.0; // 6 gap + 1 divider + 10 gap
    final cardInnerHeight =
        rows.length * rowHeight + (amountIndex > 0 ? dividerBlock : 0.0);
    final footerHeight = 48.0 + _wrappedLineCount(_footer, 13.0, _width - 56) * 20.0 + 36.0;

    final pageHeight = headerHeight +
        dateHeight +
        (20.0 + 20.0 + cardInnerHeight + 20.0) +
        footerHeight +
        20.0; // safety buffer so wrapped text is never clipped

    final doc = pw.Document();
    final header = await _header();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(_width, pageHeight, marginAll: 0),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            header,
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  receipt.receiptDateTime ?? receipt.receiptDate ?? '',
                  style: pw.TextStyle(fontSize: 15, color: _ink),
                ),
              ),
            ),
            pw.Container(
              margin: const pw.EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              decoration: pw.BoxDecoration(
                color: _cardBg,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  for (final (index, (label, value, bold)) in rows.indexed) ...[
                    if (index == amountIndex && amountIndex > 0) ...[
                      pw.SizedBox(height: 6),
                      pw.Divider(
                        color: _divider,
                        height: 1,
                        thickness: 1,
                      ),
                      pw.SizedBox(height: 10),
                    ],
                    _row(label, value, bold: bold),
                  ],
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 48, 28, 36),
              child: pw.Text(
                _footer,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 13,
                  lineSpacing: 1.5,
                  color: _muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static Future<pw.Widget> _header() async {
    final logo = await _logo();
    return pw.Container(
      color: _headerBg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          logo,
          pw.Text(
            'RECEIPT',
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: _receiptWord,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Rasterises the brand mark from its SVG asset so it can be embedded in the
  /// PDF. Falls back to a plain wordmark if the SVG cannot be decoded.
  static Future<pw.Widget> _logo() async {
    try {
      final svgText = await rootBundle.loadString(SvgImages.icon);
      final info = await vg.loadPicture(SvgStringLoader(svgText), null);
      final image = await info.picture.toImage(
        info.size.width.toInt(),
        info.size.height.toInt(),
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      info.picture.dispose();
      if (data == null) return _wordmark();
      return pw.Image(
        pw.MemoryImage(data.buffer.asUint8List()),
        height: 34,
        width: 34 * info.size.width / info.size.height,
      );
    } catch (_) {
      return _wordmark();
    }
  }

  static pw.Widget _wordmark() {
    return pw.Text(
      'BigPay',
      style: pw.TextStyle(
        fontSize: 26,
        fontWeight: pw.FontWeight.bold,
        color: _ink,
      ),
    );
  }

  static pw.Widget _row(String label, String value, {required bool bold}) {
    final weight =
        bold ? pw.FontWeight.bold : pw.FontWeight.normal;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 15,
                color: _muted,
                fontWeight: weight,
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 15,
                color: _ink,
                fontWeight: weight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// (label, value, bold) rows: the service, then the server's preview rows.
  static List<(String, String, bool)> _rows(RequestResponse receipt) {
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

  /// Crude wrapped-line estimate used to size the footer block without
  /// clipping: average glyph width ≈ 0.5 × fontSize.
  static int _wrappedLineCount(String text, double fontSize, double maxWidth) {
    final perLine = (maxWidth / (fontSize * 0.5)).floor().clamp(1, 1 << 30);
    return (text.length / perLine).ceil().clamp(1, 1 << 30);
  }
}