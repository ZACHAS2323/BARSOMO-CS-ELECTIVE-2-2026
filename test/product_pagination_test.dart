import 'package:flutter_ecommerce_app/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product pages use six-item zero-based ranges', () {
    expect(productPageRange(0), (start: 0, end: 5));
    expect(productPageRange(1), (start: 6, end: 11));
    expect(productPageRange(2), (start: 12, end: 17));
  });

  test('product page range rejects negative page indexes', () {
    expect(() => productPageRange(-1), throwsArgumentError);
  });
}
