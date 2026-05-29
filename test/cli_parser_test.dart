import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('CliParser.parse', () {
    test('parses a flag and an option', () {
      final cli = const CliParser(
        title: 'tool',
        params: [
          Flag(name: 'help', abbr: 'h', defaultsTo: false),
          OptionParam(name: 'input', abbr: 'i', defaultsTo: '.'),
        ],
      );
      final (results, _) = cli.parse(['--help', '-i', 'lib']);
      expect(results.flag('help'), isTrue);
      expect(results.option('input'), 'lib');
    });

    test('options use defaultsTo when omitted', () {
      final cli = const CliParser(
        params: [
          OptionParam(name: 'input', defaultsTo: '.'),
        ],
      );
      final (r, _) = cli.parse([]);
      expect(r.option('input'), '.');
    });

    test('multi-option splits commas by default', () {
      final cli = const CliParser(
        params: [
          MultiOptionParam(name: 'roots', abbr: 'r'),
        ],
      );
      final (r, _) = cli.parse(['-r', 'a,b,c']);
      expect(r.multiOption('roots'), ['a', 'b', 'c']);
    });

    test('getInfo builds a usage string with title and example', () {
      final cli = const CliParser(
        title: 'mytool',
        description: 'does things',
        example: 'mytool -i .',
        params: [
          Flag(name: 'help'),
        ],
      );
      final (_, parser) = cli.parse([]);
      final info = cli.getInfo(parser);
      expect(info, contains('mytool'));
      expect(info, contains('does things'));
      expect(info, contains('mytool -i .'));
    });
  });

  group('Param subclasses', () {
    test('Flag.copyWith preserves and overrides fields', () {
      const f = Flag(name: 'a', defaultsTo: false);
      final f2 = f.copyWith(name: 'b', defaultsTo: true);
      expect(f2.name, 'b');
      expect(f2.defaultsTo, isTrue);
    });

    test('OptionParam.copyWith', () {
      const o = OptionParam(name: 'a');
      final o2 = o.copyWith(defaultsTo: 'x');
      expect(o2.defaultsTo, 'x');
    });

    test('MultiOptionParam.copyWith', () {
      const m = MultiOptionParam(name: 'a');
      final m2 = m.copyWith(defaultsTo: ['x']);
      expect(m2.defaultsTo, ['x']);
    });

    test('Params with equal names are equal', () {
      const a = Flag(name: 'help');
      const b = OptionParam(name: 'help');
      expect(a, equals(b));
    });
  });

  group('Default* enums', () {
    test('DefaultFlags.HELP', () {
      expect(DefaultFlags.HELP.name, 'help');
      expect(DefaultFlags.HELP.flag.name, 'help');
    });

    test('DefaultOptionParams.INPUT_PATH', () {
      expect(DefaultOptionParams.INPUT_PATH.name, 'input');
      expect(DefaultOptionParams.INPUT_PATH.option.abbr, 'i');
    });

    test('DefaultMultiOptions.TEMPLATES', () {
      expect(DefaultMultiOptions.TEMPLATES.name, 'templates');
      expect(DefaultMultiOptions.TEMPLATES.multiOption.abbr, 't');
    });
  });

  group('ExitCodes', () {
    test('canonical codes', () {
      expect(ExitCodes.SUCCESS.code, 0);
      expect(ExitCodes.FAILURE.code, 1);
      expect(ExitCodes.USAGE.code, 64);
    });
  });
}
