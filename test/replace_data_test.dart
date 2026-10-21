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

    test('independent keys are all replaced', () {
      final r = replaceData('aXa', {
        'X': 'Y',
        'a': 'b',
      });
      expect(r, 'bYb');
    });

    test('single pass — a substituted value is never substituted again', () {
      final r = replaceData('{a} {b}', {
        '{a}': '{b}',
        '{b}': 'X',
      });
      expect(r, '{b} X');
    });

    test('single pass — a value is not re-matched by an earlier key either',
        () {
      final r = replaceData('{a} {b}', {
        '{b}': '{a}',
        '{a}': 'X',
      });
      expect(r, 'X {a}');
    });

    test('single pass — a match never spans a substituted value', () {
      // Replacing one after another would turn 'xAy' into 'xBy' and then
      // match 'xB' as a whole.
      final r = replaceData('xAy', {
        'A': 'B',
        'xB': 'WRONG',
      });
      expect(r, 'xBy');
    });

    test('overlapping keys — the key listed first wins', () {
      expect(replaceData('ab', {'b': 'X', 'ab': 'Y'}), 'aX');
      expect(replaceData('ab', {'ab': 'Y', 'b': 'X'}), 'Y');
    });

    test('zero-width patterns insert without consuming text', () {
      expect(replaceData('ab', {RegExp('^'): '>', 'a': 'A'}), '>Ab');
      expect(replaceData('ab', {'a': 'A', RegExp(r'$'): '<'}), 'Ab<');
      expect(replaceData('ab', {'a': 'A', RegExp('^'): '>'}), '>Ab');
    });

    test('a value containing regex or interpolation syntax is literal', () {
      final r = replaceData('v = X;', {'X': r'$1 ${y} \\'});
      expect(r, r'v = $1 ${y} \\;');
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
