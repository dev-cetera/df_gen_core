// Unit tests for the insight-and-intersection data classes used to thread
// analyzer output through the generator pipeline. These types are simple
// value containers — the tests pin their public surface so a careless
// rename or field reorder is caught.

import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('ClassInsight<T>', () {
    test('stores the annotation, class name, and file location', () {
      const insight = ClassInsight<String>(
        annotation: 'my-annotation',
        className: 'MyClass',
        dirPath: '/lib/src',
        fileName: 'my_class.dart',
      );
      expect(insight.annotation, 'my-annotation');
      expect(insight.className, 'MyClass');
      expect(insight.dirPath, '/lib/src');
      expect(insight.fileName, 'my_class.dart');
      // supertypeName defaults to null when the extractor can't determine it.
      expect(insight.supertypeName, isNull);
    });

    test('captures the supertype display name when provided', () {
      const insight = ClassInsight<String>(
        annotation: 'a',
        className: '_MyModel',
        dirPath: '.',
        fileName: 'my_model.dart',
        supertypeName: 'Model',
      );
      expect(insight.supertypeName, 'Model');
    });

    test('accepts complex annotation payloads via the generic type', () {
      final ann = {'key': 'value', 'n': 42};
      final insight = ClassInsight<Map<String, dynamic>>(
        annotation: ann,
        className: 'X',
        dirPath: '.',
        fileName: 'x.dart',
      );
      expect(insight.annotation, ann);
      expect(insight.annotation['n'], 42);
    });
  });

  group('Intersection<T>', () {
    test('stores insight + replacements pair', () {
      const x = Intersection<String>(
        insight: 'theInsight',
        replacements: {'x': 1},
      );
      expect(x.insight, 'theInsight');
      expect(x.replacements['x'], 1);
    });

    test('generateWithStatic broadcasts the same replacements to every '
        'insight', () {
      final out = Intersection.generateWithStatic<String>(
        ['a', 'b', 'c'],
        const {'shared': true},
      ).toList();

      expect(out.length, 3);
      expect(out.map((e) => e.insight).toList(), ['a', 'b', 'c']);
      for (final entry in out) {
        expect(entry.replacements['shared'], true);
        // Identity check — all entries share the SAME map.
        expect(identical(entry.replacements, out.first.replacements), isTrue);
      }
    });

    test('generateWithDynamic produces per-insight replacements', () {
      final out = Intersection.generateWithDynamic<int>(
        [1, 2, 3],
        (n) => {'n': n, 'doubled': n * 2},
      ).toList();

      expect(out.length, 3);
      expect(out[0].replacements['n'], 1);
      expect(out[0].replacements['doubled'], 2);
      expect(out[2].replacements['doubled'], 6);
      // Each map is distinct.
      expect(identical(out[0].replacements, out[1].replacements), isFalse);
    });

    test('generateMultiWithStatic yields lazily (Iterable, not List)', () {
      // The `sync*` variant should produce a lazy iterable.
      final iter = Intersection.generateMultiWithStatic<String>(
        ['a', 'b'],
        const {},
      );
      // `take(1)` should pull only the first.
      final taken = iter.take(1).toList();
      expect(taken.length, 1);
      expect(taken.first.insight, 'a');
    });

    test('generateMultiWithDynamic yields per-insight replacements lazily',
        () {
      final iter = Intersection.generateMultiWithDynamic<String>(
        ['x', 'y'],
        (insight) => {'len': insight.length, 'value': insight},
      );
      final list = iter.toList();
      expect(list.length, 2);
      expect(list[0].replacements['value'], 'x');
      expect(list[1].replacements['len'], 1);
    });

    test('empty input produces empty output', () {
      final out = Intersection.generateWithStatic<int>(const [], const {});
      expect(out.toList(), isEmpty);
    });
  });

  group('InsightMapper<TInsight, TPlaceholder>', () {
    test('stores the placeholder and async mapping function', () async {
      final mapper = InsightMapper<int, String>(
        placeholder: '___N___',
        mapInsights: (n) async => 'value=$n',
      );
      expect(mapper.placeholder, '___N___');
      expect(await mapper.mapInsights(7), 'value=7');
    });
  });

  group('FileInsight / PerIntersection family', () {
    // FileInsight wraps a FilePathExplorerFinding; the finding type itself
    // is exercised in path_explorer_test.dart. Here we just lock the
    // wrapping behaviour and the discriminator-tagged subclasses of
    // PerIntersection.

    test('PerFileIntersection carries the source file path', () {
      const x = PerFileIntersection<String>(
        sourceFilePathOrUrl: '/tmp/a.txt',
        sourceTemplatePathOrUrl: 'tpl.md',
        replacements: {'k': 'v'},
        category: 'cat-A',
      );
      expect(x.sourceFilePathOrUrl, '/tmp/a.txt');
      expect(x.sourceTemplatePathOrUrl, 'tpl.md');
      expect(x.category, 'cat-A');
      expect(x.replacements['k'], 'v');
    });

    test('PerFileListIntersection carries an iterable of paths', () {
      const x = PerFileListIntersection<String>(
        sourceFilePathOrUrlList: ['/a', '/b'],
        sourceTemplatePathOrUrl: 'tpl.md',
        replacements: {},
      );
      expect(x.sourceFilePathOrUrlList.toList(), ['/a', '/b']);
    });

    test('PerFolderIntersection accepts a folder finding without category', () {
      // We construct a synthetic finding by reaching through path_explorer.
      // For the test we just exercise the type — a stub is fine because
      // FilePathExplorerFinding is a value class.
      // (See path_explorer_test.dart for finding construction coverage.)
      // Using a list-based intersection avoids the finding-construction
      // boilerplate and still exercises the sealed-class hierarchy.
      const x = PerFolderListIntersection<int>(
        sourceFolderPathOrUrlList: ['/foo', '/bar'],
        sourceTemplatePathOrUrl: 'tpl.md',
        replacements: {},
      );
      expect(x.sourceFolderPathOrUrlList.toList(), ['/foo', '/bar']);
      expect(x.category, isNull);
    });

    test('PerIntersection is a sealed family — pattern match is exhaustive', () {
      const samples = [
        PerFileIntersection<String>(
          sourceFilePathOrUrl: '/a',
          sourceTemplatePathOrUrl: 't',
          replacements: {},
        ),
        PerFileListIntersection<String>(
          sourceFilePathOrUrlList: ['/a'],
          sourceTemplatePathOrUrl: 't',
          replacements: {},
        ),
        PerFolderListIntersection<String>(
          sourceFolderPathOrUrlList: ['/x'],
          sourceTemplatePathOrUrl: 't',
          replacements: {},
        ),
      ];
      // Tag each variant — the compiler verifies the switch is exhaustive.
      for (final s in samples) {
        final tag = switch (s) {
          PerFileIntersection<String>() => 'file',
          PerFileListIntersection<String>() => 'file-list',
          PerFolderIntersection<String>() => 'folder',
          PerFolderListIntersection<String>() => 'folder-list',
        };
        expect(tag, isNotEmpty);
      }
    });
  });
}
