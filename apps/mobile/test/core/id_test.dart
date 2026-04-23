import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/id.dart';

void main() {
  test('newId returns 36-char UUID string', () {
    final id = newId();
    expect(id.length, 36);
    expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(id), isTrue);
  });

  test('newId generates time-ordered values across milliseconds', () async {
    final a = newId();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final b = newId();
    // v7 UUIDs have a ms-precision time prefix; within a single ms the
    // random tail can go either way, so only compare across a real delay.
    expect(a.compareTo(b), lessThan(0));
  });
}
