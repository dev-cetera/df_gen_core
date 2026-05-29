import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('Intersection.generateWithStatic', () {
    test('emits one entry per insight with the shared map', () {
      final m = {'k': 1};
      final list = Intersection.generateWithStatic(['a', 'b'], m).toList();
      expect(list.length, 2);
      expect(list.every((e) => identical(e.replacements, m)), isTrue);
      expect(list.map((e) => e.insight).toList(), ['a', 'b']);
    });

    test('empty insights yields empty iterable', () {
      final list = Intersection.generateWithStatic<int>(
        const <int>[],
        const {},
      ).toList();
      expect(list, isEmpty);
    });
  });

  group('Intersection.generateWithDynamic', () {
    test('invokes the builder per insight', () {
      final list = Intersection.generateWithDynamic<int>(
        [1, 2],
        (i) => {'v': i * 10},
      ).toList();
      expect(list[0].replacements, {'v': 10});
      expect(list[1].replacements, {'v': 20});
    });
  });

  group('Intersection.generateMultiWithStatic (sync generator)', () {
    test('yields lazily and each entry shares the same replacements map', () {
      final m = {'k': 1};
      final iter = Intersection.generateMultiWithStatic([1, 2, 3], m);
      final list = iter.toList();
      expect(list.length, 3);
      expect(list.every((e) => identical(e.replacements, m)), isTrue);
    });
  });

  group('Intersection.generateMultiWithDynamic (sync generator)', () {
    test('builds replacements per yield', () {
      final iter = Intersection.generateMultiWithDynamic<String>(
        ['a', 'b'],
        (s) => {'n': s.length},
      );
      final list = iter.toList();
      expect(list[0].replacements, {'n': 1});
      expect(list[1].replacements, {'n': 1});
    });
  });
}
