import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('TemplateInterpolator.interpolate', () {
    test('replaces placeholders from a single insight', () {
      final ti = TemplateInterpolator<Map<String, String>>({
        '___NAME___': (i) => i['name']!,
        '___AGE___': (i) => i['age']!,
      });
      final out = ti.interpolate('Hi ___NAME___ (___AGE___).', {
        'name': 'Ada',
        'age': '30',
      });
      expect(out, 'Hi Ada (30).');
    });

    test('placeholders not in the map are left untouched', () {
      final ti = TemplateInterpolator<Map<String, String>>({
        '___NAME___': (i) => i['name']!,
      });
      final out = ti.interpolate('___NAME___ ___UNKNOWN___', {'name': 'A'});
      expect(out, contains('A'));
      expect(out, contains('___UNKNOWN___'));
    });

    test('an inserted value that looks like a placeholder stays as written',
        () {
      final ti = TemplateInterpolator<Map<String, String>>({
        '___A___': (i) => i['a']!,
        '___B___': (i) => i['b']!,
      });
      final out = ti.interpolate('___A___ ___B___', {
        'a': '___B___',
        'b': 'X',
      });
      expect(out, '___B___ X');
    });
  });

  group('TemplateInterpolator.interpolateAndJoin', () {
    test('joins outputs from multiple insights with separator', () {
      final ti = TemplateInterpolator<int>({
        '___X___': (i) => '#$i',
      });
      final out = ti.interpolateAndJoin('___X___', [1, 2, 3]);
      expect(out, '#1\n#2\n#3');
    });

    test('custom separator', () {
      final ti = TemplateInterpolator<int>({
        '___X___': (i) => '$i',
      });
      final out = ti.interpolateAndJoin('___X___', [1, 2], separator: ', ');
      expect(out, '1, 2');
    });

    test('joined values are not substituted again', () {
      final ti = TemplateInterpolator<String>({
        '___X___': (i) => i,
        '___Y___': (i) => 'y',
      });
      final out = ti.interpolateAndJoin('___X___|___Y___', ['___Y___', 'a']);
      expect(out, '___Y___\na|y\ny');
    });
  });
}
