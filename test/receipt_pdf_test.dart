import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/data/models/general_flow/form_verification_response.dart';
import 'package:bigpay/data/models/general_flow/request_response.dart';
import 'package:bigpay/ui/components/history/receipt_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ReceiptPdf.build produces a valid PDF that looks like the receipt', () async {
    final receipt = RequestResponse(
      receiptId: 'TXN-123',
      reference: 'REF-456',
      amount: 'GHS 10.00',
      status: 1,
      statusLabel: 'Successful',
      formName: 'MTN Mobile Money',
      activityName: 'Money Transfer',
      receiptDateTime: '2026-10-02 14:30:00',
      previewData: const [
        PreviewData(key: 'Recipient', value: '0244000000'),
        PreviewData(key: 'Amount', value: 'GHS 10.00'),
        PreviewData(key: 'Total', value: 'GHS 10.30'),
      ],
    );

    final bytes = await ReceiptPdf.build(receipt);

    // Must be a real PDF file, not text.
    expect(utf8Tag(bytes), isTrue, reason: 'should be a PDF, not plain text');
    final trailer = String.fromCharCodes(bytes.sublist(bytes.length - 32));
    expect(trailer.contains('%%EOF'), isTrue);

    // And it must materialise as a file shareable via share_plus.
    final dir = Directory.systemTemp.createTempSync('receipt_pdf_test');
    final file = File('${dir.path}/receipt_TXN-123.pdf');
    await file.writeAsBytes(bytes);
    expect(file.readAsBytesSync().length, greaterThan(1000));
  });
}

bool utf8Tag(Uint8List bytes) {
  if (bytes.length < 5) return false;
  return String.fromCharCodes(bytes.take(5)) == '%PDF-';
}