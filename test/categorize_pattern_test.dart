import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('CategorizedPattern.categorize', () {
    test('returns matching category', () {
      final result = CategorizedPattern.categorize('hello.dart', [
        const CategorizedPattern(pattern: r'\.go$', category: 'go'),
        const CategorizedPattern(pattern: r'\.dart$', category: 'dart'),
      ]);
      expect(result, 'dart');
    });

    test('matching is case-insensitive', () {
      final result = CategorizedPattern.categorize('FOO.DART', [
        const CategorizedPattern(pattern: r'\.dart$', category: 'dart'),
      ]);
      expect(result, 'dart');
    });

    test('returns null when no pattern matches', () {
      final result = CategorizedPattern.categorize('hello.go', [
        const CategorizedPattern(pattern: r'\.dart$', category: 'dart'),
      ]);
      expect(result, isNull);
    });

    test('returns null for empty patterns iterable', () {
      final result = CategorizedPattern.categorize<String>('x', []);
      expect(result, isNull);
    });
  });

  group('CategorizedPattern.matchesAny', () {
    test('throws on empty patterns', () {
      expect(
        () => CategorizedPattern.matchesAny<void>('x', const []),
        throwsArgumentError,
      );
    });

    test('true when any pattern matches', () {
      expect(
        CategorizedPattern.matchesAny('x.dart', [
          const CategorizedPattern<void>(pattern: r'\.go$'),
          const CategorizedPattern<void>(pattern: r'\.dart$'),
        ]),
        isTrue,
      );
    });

    test('false when none matches', () {
      expect(
        CategorizedPattern.matchesAny('x.rs', [
          const CategorizedPattern<void>(pattern: r'\.go$'),
          const CategorizedPattern<void>(pattern: r'\.dart$'),
        ]),
        isFalse,
      );
    });
  });

  group('CategorizedPattern.matchesAll', () {
    test('throws on empty patterns', () {
      expect(
        () => CategorizedPattern.matchesAll<void>('x', const []),
        throwsArgumentError,
      );
    });

    test('true only when every pattern matches', () {
      expect(
        CategorizedPattern.matchesAll('hello_world.dart', [
          const CategorizedPattern<void>(pattern: r'^hello'),
          const CategorizedPattern<void>(pattern: r'\.dart$'),
        ]),
        isTrue,
      );
    });

    test('false when any one fails', () {
      expect(
        CategorizedPattern.matchesAll('hello_world.dart', [
          const CategorizedPattern<void>(pattern: r'^bye'),
          const CategorizedPattern<void>(pattern: r'\.dart$'),
        ]),
        isFalse,
      );
    });
  });

  group('CategorizedPattern.doesMatch', () {
    test('case-insensitive substring match', () {
      expect(
        CategorizedPattern.doesMatch(
          'FOO.dart',
          const CategorizedPattern<void>(pattern: r'^foo'),
        ),
        isTrue,
      );
    });
  });

  test('regExp getter compiles the pattern', () {
    const cp = CategorizedPattern<int>(pattern: r'\d+', category: 1);
    expect(cp.regExp.hasMatch('abc123'), isTrue);
  });

  test('DEFAULT sentinel is exposed', () {
    expect(CategorizedPattern.DEFAULT, isNotNull);
  });
}
