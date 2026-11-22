import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter_activity/models/catalog.dart';

void main() {
  test('pagination creates six-item zero-based Supabase ranges', () {
    expect(pageRange(0), (start: 0, end: 5));
    expect(pageRange(1), (start: 6, end: 11));
    expect(pageRange(2), (start: 12, end: 17));
  });
}
