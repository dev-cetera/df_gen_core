import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('PathUtility.i', () {
    test('localize converts forward slashes to local separator', () {
      final r = PathUtility.i.localize('a/b/c');
      // On Unix this stays 'a/b/c'; on Windows this becomes 'a\\b\\c'.
      // Both forms must round-trip back through components.
      final parts = PathUtility.i.components(r);
      expect(parts, ['a', 'b', 'c']);
    });

    test('localize handles backslashes too', () {
      final parts = PathUtility.i.components(r'a\b\c');
      expect(parts, ['a', 'b', 'c']);
    });

    test('localBaseName works for mixed separators', () {
      expect(PathUtility.i.localBaseName('lib/src/foo.dart'), 'foo.dart');
      expect(PathUtility.i.localBaseName(r'lib\src\foo.dart'), 'foo.dart');
    });

    test('localBaseNameWithoutExtension', () {
      expect(
        PathUtility.i.localBaseNameWithoutExtension('lib/src/foo.dart'),
        'foo',
      );
    });

    test('localDirName', () {
      expect(PathUtility.i.localDirName('lib/src/foo.dart'), endsWith('src'));
    });

    test('folderName returns parent folder of the path', () {
      // 'lib/src/foo.dart' → parent is 'src'.
      expect(PathUtility.i.folderName('lib/src/foo.dart'), 'src');
    });
  });

  group('matchesAnyPathPattern', () {
    test('returns true when patterns is empty', () {
      expect(matchesAnyPathPattern('anything', const {}), isTrue);
    });

    test('returns true when any pattern matches', () {
      expect(matchesAnyPathPattern('lib/src/foo.dart', {r'\.dart$'}), isTrue);
    });

    test('returns false when no pattern matches', () {
      expect(matchesAnyPathPattern('lib/src/foo.dart', {r'\.go$'}), isFalse);
    });
  });

  group('matchesAnyExtension', () {
    test('returns true when extensions is empty', () {
      expect(matchesAnyExtension('foo.dart', const {}), isTrue);
    });

    test('case sensitive matches', () {
      expect(matchesAnyExtension('foo.dart', {'.dart'}), isTrue);
      expect(matchesAnyExtension('foo.DART', {'.dart'}), isFalse);
    });

    test('case insensitive matches', () {
      expect(
        matchesAnyExtension('foo.DART', {'.dart'}, caseSensitive: false),
        isTrue,
      );
    });
  });

  group('isPrivateFileName', () {
    test('basename starting with underscore is private', () {
      expect(isPrivateFileName('lib/src/_index.dart'), isTrue);
    });

    test('basename not starting with underscore is public', () {
      expect(isPrivateFileName('lib/src/index.dart'), isFalse);
    });

    test('directory-level underscores do not count', () {
      expect(isPrivateFileName('lib/_internal/index.dart'), isFalse);
    });
  });

  group('isMatchingFileName', () {
    test('matches both begType and endType (case-insensitive)', () {
      final r = isMatchingFileName('foo_bar.dart', 'foo', 'dart');
      expect(r.status, isTrue);
      expect(r.fileName, 'foo_bar.dart');
    });

    test('returns false when endType differs', () {
      final r = isMatchingFileName('foo_bar.go', 'foo', 'dart');
      expect(r.status, isFalse);
    });

    test('empty begType accepts any leading text', () {
      final r = isMatchingFileName('anything.dart', '', 'dart');
      expect(r.status, isTrue);
    });

    test('empty endType accepts any extension', () {
      final r = isMatchingFileName('foo_anything', 'foo', '');
      expect(r.status, isTrue);
    });
  });

  group('combinePathSets', () {
    test('single set', () {
      expect(
        combinePathSets([
          {'a', 'b'},
        ]),
        {'a', 'b'},
      );
    });

    test('two sets produce cartesian-joined paths', () {
      final r = combinePathSets([
        {'lib'},
        {'src', 'test'},
      ]);
      expect(r.length, 2);
      expect(r.any((p) => p.endsWith('src')), isTrue);
      expect(r.any((p) => p.endsWith('test')), isTrue);
    });

    test('empty sets are skipped', () {
      final r = combinePathSets([
        {'lib'},
        const <String>{},
        {'a'},
      ]);
      // The set is filtered to only {lib} and {a}, then joined.
      expect(r, anyElement(endsWith('a')));
    });

    test('empty input returns empty set', () {
      expect(combinePathSets([]), <String>{});
    });
  });

  group('previewPath', () {
    test('takes last 3 segments', () {
      final r = previewPath('a/b/c/d/e/f');
      // Order-preserving last 3 from the path library on this platform.
      expect(r.startsWith('**'), isTrue);
      expect(r.endsWith('f'), isTrue);
    });
  });

  group('pathContainsComponent', () {
    test('detects component (case-insensitive)', () {
      expect(pathContainsComponent('lib/src/foo.dart', {'SRC'}), isTrue);
    });

    test('does not match substrings of components', () {
      expect(pathContainsComponent('lib/source/foo.dart', {'src'}), isFalse);
    });
  });
}
