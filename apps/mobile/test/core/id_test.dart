import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/id.dart';

void main() {
  test('newId returns 36-char UUID string', () {
    final id = newId();
    expect(id.length, 36);
    expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(id), isTrue);
  });

  test('newId generates monotonically increasing values within same ms', () async {
    final a = newId();
    final b = newId();
    expect(a.compareTo(b), lessThanOrEqualTo(0));
  });
}
