import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/pdf_reader/presentation/widgets/purchased_pdf_reader_loader.dart';

void main() {
  test('keeps the purchase identity for private file preparation', () {
    const PurchasedPdfReaderLoader loader = PurchasedPdfReaderLoader(
      purchaseId: 'purchase-1',
      name: 'Book',
    );

    expect(loader.purchaseId, 'purchase-1');
    expect(loader.name, 'Book');
  });
}
