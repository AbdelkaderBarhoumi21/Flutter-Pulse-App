import 'package:flutter_pulse_app/core/extensions/string_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isBlank', () {
    expect(''.isBlank, isTrue);
    expect('  \n\t'.isBlank, isTrue);
    expect(' a '.isBlank, isFalse);
  });

  test('isNullOrBlank', () {
    String? value;
    expect(value.isNullOrBlank, isTrue);
    value = ' ';
    expect(value.isNullOrBlank, isTrue);
    value = 'x';
    expect(value.isNullOrBlank, isFalse);
  });
}
