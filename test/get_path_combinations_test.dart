import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('GetPathCombinations', () {
    test('cartesian-joins all sets and returns paths', () {
      final g = GetPathCombinations([
        {'lib'},
        {'src', 'test'},
      ]);
      final r = g();
      expect(r.length, 2);
      expect(r.any((e) => e.endsWith('src')), isTrue);
      expect(r.any((e) => e.endsWith('test')), isTrue);
    });

    test('filters by pathPatterns when supplied', () {
      final g = GetPathCombinations(
        [
          {'lib'},
          {'src', 'test'},
        ],
        pathPatterns: {r'src$'},
      );
      final r = g();
      // Only 'lib/src' matches the pattern.
      expect(r.length, 1);
      expect(r.first, endsWith('src'));
    });

    test('equality compares values', () {
      final a = GetPathCombinations([
        {'lib'},
        {'src'},
      ]);
      final b = GetPathCombinations([
        {'lib'},
        {'src'},
      ]);
      expect(a, equals(b));
    });
  });
}
