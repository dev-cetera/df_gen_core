import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('filterMappersByType', () {
    test('returns only matching regexes', () {
      final mappers = newTypeMap<MapperEvent>({
        r'^(String)\??$': (e) => 'S',
        r'^(int)\??$': (e) => 'I',
      });
      expect(filterMappersByType(mappers, 'String').length, 1);
      expect(filterMappersByType(mappers, 'int').length, 1);
      expect(filterMappersByType(mappers, 'double'), isEmpty);
    });

    test('preserves insertion order so specific patterns win over catchalls',
        () {
      final mappers = newTypeMap<MapperEvent>({
        r'^(String)\??$': (e) => 'S',
        r'^(\w+)\??$': (e) => 'ANY',
      });
      final filtered = filterMappersByType(mappers, 'String');
      // Both regexes match, so both entries are returned in insertion order.
      expect(filtered.length, 2);
      expect(filtered.entries.first.value(ObjectMapperEvent()), 'S');
    });
  });

  group('buildObjectMapper', () {
    test('produces formula from a matching mapper', () {
      final mappers = newTypeMap<MapperEvent>({
        r'^(int)\??$': (e) => 'INT(${e.name})',
      });
      final r = buildObjectMapper('int', 'age', mappers);
      expect(r, 'INT(age)');
    });

    test(
        'returns null when no mapper matches (with assert disabled in release)',
        () {
      final mappers = newTypeMap<MapperEvent>({
        r'^(int)\??$': (e) => 'INT(${e.name})',
      });
      // In assertions-enabled mode (default for `dart test`), an unmatched
      // type triggers an assert. So we only verify the assert fires.
      expect(
        () => buildObjectMapper('Widget', 'w', mappers),
        throwsA(isA<AssertionError>()),
      );
    });

    test('optional non-matching regex groups are coerced to empty (regression)',
        () {
      // The mapper's regex has an optional `(\?)?` group; for a non-nullable
      // type like `int` that group never matches. The mapper interpolates
      // every captured group via matchGroups, so the previous `match.group(i)!`
      // would crash on the unmatched optional group. Verify it now produces
      // an empty string instead.
      final mappers = newTypeMap<MapperEvent>({
        r'^(int)(\?)?$': (e) {
          final groups = e.matchGroups!.toList();
          // groups[0]=full match, groups[1]='int', groups[2]='' or '?'
          return 'I(${e.name}|null=${groups[2]})';
        },
      });
      final r = buildObjectMapper('int', 'age', mappers);
      expect(r, 'I(age|null=)');
    });

    test('ObjectMapperEvent.custom exposes name and matchGroups', () {
      final e = ObjectMapperEvent.custom('thing', ['a', 'b']);
      expect(e.name, 'thing');
      expect(e.matchGroups, ['a', 'b']);
    });
  });

  group('buildCollectionMapper: missing-mapper sentinel', () {
    test('throws on missing collection mapper in assert-enabled mode', () {
      // Build the collection without giving it a matching mapper. With asserts
      // enabled (the test runner default) the AssertionError fires. The fix
      // also writes a `MISSING_MAPPER_FOR(...)` sentinel into the output in
      // release mode so generated code never silently contains stray `#x0`
      // placeholders, but we can't observe release-mode output from a test.
      final mappers = newTypeMap<MapperEvent>({
        // Only an object mapper for int — no collection mapper for List<int>.
        r'^int\??$': (e) => 'I(${e.name})',
      });
      expect(
        () => buildCollectionMapper(
          const [
            ['', 'List<int>', 'int'],
          ],
          mappers,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('newTypeMap', () {
    test('returns an unmodifiable map', () {
      final m = newTypeMap<MapperEvent>({});
      expect(
        () => m['x'] = (e) => 'x',
        throwsUnsupportedError,
      );
    });
  });

  group('buildCollectionMapper', () {
    test('builds a flat mapper for List<int>', () {
      final mappers = newTypeMap<MapperEvent>({
        // Collection mapper template: emits its element-slot placeholders
        // (#p0, #p1, ...) — those get substituted later by the matching
        // object mappers.
        r'^List<.*>\??$': (e) {
          final c = e as CollectionMapperEvent;
          return 'LIST(${c.hashes})';
        },
        // Object mapper for int.
        r'^int\??$': (e) => 'I(${e.name})',
      });
      // typeData represents the nested type tree. Each entry is
      // [<outer>, <self>, <innerType0>, <innerType1>, ...].
      // For List<int>: the outermost element advertises List<int> as self
      // and int as its single inner type.
      final r = buildCollectionMapper(
        const [
          ['', 'List<int>', 'int'],
        ],
        mappers,
      );
      // Final output should have substituted the LIST wrapper with the
      // generated p0 (its inner) which is then resolved by the int mapper.
      expect(r, contains('LIST'));
      expect(r, contains('I(p0)'));
      // No unresolved placeholders.
      expect(r.contains('#x'), isFalse);
      expect(r.contains('#p'), isFalse);
    });
  });
}
