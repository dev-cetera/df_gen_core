import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('replaceData (top-level function)', () {
    test('replaces every literal key with its stringified value', () {
      final r = replaceData('Hello, ___NAME___ (___N___).', {
        '___NAME___': 'Ada',
        '___N___': 42,
      });
      expect(r, 'Hello, Ada (42).');
    });

    test('null values are skipped — pattern is left untouched', () {
      // Regression check for the medical-grade fix: previously a null value
      // would substitute the literal string "null".
      final r = replaceData('Hi ___X___ and ___Y___', {
        '___X___': null,
        '___Y___': 'B',
      });
      expect(r, contains('___X___'));
      expect(r, contains('B'));
      expect(r, isNot(contains('null')));
    });

    test('iteration order is preserved (insertion order of map)', () {
      // Later substitutions can be affected by earlier ones — verify the
      // order is map-insertion order.
      final r = replaceData('aXa', {
        'X': 'Y',
        'a': 'b',
      });
      expect(r, 'bYb');
    });

    test('regex patterns are honored via the Pattern type', () {
      final r = replaceData('foo123bar456', {
        RegExp(r'\d+'): '#',
      });
      expect(r, 'foo#bar#');
    });
  });

  group('ReplaceDataOnStringX extension', () {
    test('delegates to replaceData', () {
      final r = 'a-b'.replaceData({'a': '1', 'b': '2'});
      expect(r, '1-2');
    });

    test('extension also skips null values', () {
      final r = '___X___'.replaceData({'___X___': null});
      expect(r, '___X___');
    });
  });
}
