import 'dart:io';

import 'package:df_gen_core/df_gen_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Lang.DART', () {
    test('code/ext/genExt/tmplExt', () {
      expect(Lang.DART.code, 'dart');
      expect(Lang.DART.ext, '.dart');
      expect(Lang.DART.genExt, '.g.dart');
      expect(Lang.DART.tmplExt, '.dart.md');
    });

    test('isValidGenFilePath / isValidSrcFilePath', () {
      expect(Lang.DART.isValidGenFilePath('foo.g.dart'), isTrue);
      expect(Lang.DART.isValidGenFilePath('foo.dart'), isFalse);
      expect(Lang.DART.isValidSrcFilePath('foo.dart'), isTrue);
      // A .g.dart file is NOT a source file.
      expect(Lang.DART.isValidSrcFilePath('foo.g.dart'), isFalse);
    });

    test('isValidTplFilePath', () {
      expect(Lang.DART.isValidTplFilePath('foo.dart.md'), isTrue);
      expect(Lang.DART.isValidTplFilePath('foo.md'), isFalse);
    });

    test('getCorrespondingSrcPathOrNull: .g.dart → .dart', () {
      final r = Lang.DART.getCorrespondingSrcPathOrNull('lib/foo.g.dart');
      expect(r, endsWith('foo.dart'));
    });

    test('getCorrespondingSrcPathOrNull: .dart → same', () {
      final r = Lang.DART.getCorrespondingSrcPathOrNull('lib/foo.dart');
      expect(r, endsWith('foo.dart'));
    });

    test('getCorrespondingSrcPathOrNull: invalid extension → null', () {
      expect(
        Lang.DART.getCorrespondingSrcPathOrNull('lib/foo.go'),
        isNull,
      );
    });

    test('getCorrespondingGenPathOrNull: .dart → .g.dart', () {
      final r = Lang.DART.getCorrespondingGenPathOrNull('lib/foo.dart');
      expect(r, endsWith('foo.g.dart'));
    });

    test('convertToGenFileName prefixes underscore and swaps ext', () {
      expect(Lang.DART.convertToGenFileName('foo.dart'), '_foo.g.dart');
    });

    test('convertToGenFileName keeps existing leading underscore', () {
      expect(Lang.DART.convertToGenFileName('_foo.dart'), '_foo.g.dart');
    });

    test('convertToSrcFileName strips the underscore', () {
      expect(Lang.DART.convertToSrcFileName('_foo.g.dart'), 'foo.dart');
    });

    test('convertToSrcFileName keeps name without leading underscore', () {
      expect(Lang.DART.convertToSrcFileName('foo.g.dart'), 'foo.dart');
    });
  });

  group('Lang has comprehensive language coverage', () {
    test('all language codes are non-empty and unique', () {
      final codes = Lang.values.map((e) => e.code).toList();
      expect(codes, isNotEmpty);
      for (final c in codes) {
        expect(c, isNotEmpty);
      }
      expect(codes.toSet().length, codes.length);
    });
  });

  group('Lang file operations (with temp dir)', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('df_gen_core_lang_');
    });

    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    test('deleteSrcFile removes a .dart source file', () async {
      final path = p.join(tmp.path, 'a.dart');
      await File(path).writeAsString('//');
      final ok = await Lang.DART.deleteSrcFile(path);
      expect(ok, isTrue);
      expect(await File(path).exists(), isFalse);
    });

    test('deleteSrcFile does not touch a .g.dart file', () async {
      final path = p.join(tmp.path, 'a.g.dart');
      await File(path).writeAsString('//');
      final ok = await Lang.DART.deleteSrcFile(path);
      expect(ok, isFalse);
      expect(await File(path).exists(), isTrue);
    });

    test('deleteGenFile removes a .g.dart file', () async {
      final path = p.join(tmp.path, 'a.g.dart');
      await File(path).writeAsString('//');
      final ok = await Lang.DART.deleteGenFile(path);
      expect(ok, isTrue);
      expect(await File(path).exists(), isFalse);
    });

    test('deleteGenFile does not touch a .dart source file', () async {
      final path = p.join(tmp.path, 'a.dart');
      await File(path).writeAsString('//');
      final ok = await Lang.DART.deleteGenFile(path);
      expect(ok, isFalse);
      expect(await File(path).exists(), isTrue);
    });

    test('srcAndGenPairExistsFor: both exist (src side)', () async {
      final src = p.join(tmp.path, 'a.dart');
      final gen = p.join(tmp.path, 'a.g.dart');
      await File(src).writeAsString('//');
      await File(gen).writeAsString('//');
      expect(await Lang.DART.srcAndGenPairExistsFor(src), isTrue);
    });

    test('srcAndGenPairExistsFor: both exist (gen side)', () async {
      final src = p.join(tmp.path, 'a.dart');
      final gen = p.join(tmp.path, 'a.g.dart');
      await File(src).writeAsString('//');
      await File(gen).writeAsString('//');
      expect(await Lang.DART.srcAndGenPairExistsFor(gen), isTrue);
    });

    test('srcAndGenPairExistsFor: missing partner returns false', () async {
      final src = p.join(tmp.path, 'a.dart');
      await File(src).writeAsString('//');
      expect(await Lang.DART.srcAndGenPairExistsFor(src), isFalse);
    });

    test('deleteAllSrcFiles only removes source files', () async {
      final src1 = p.join(tmp.path, 'one.dart');
      final src2 = p.join(tmp.path, 'two.dart');
      final gen = p.join(tmp.path, 'two.g.dart');
      await File(src1).writeAsString('//');
      await File(src2).writeAsString('//');
      await File(gen).writeAsString('//');
      await Lang.DART.deleteAllSrcFiles(tmp.path);
      expect(await File(src1).exists(), isFalse);
      expect(await File(src2).exists(), isFalse);
      expect(await File(gen).exists(), isTrue);
    });

    test('deleteAllGenFiles only removes generated files', () async {
      final src = p.join(tmp.path, 'a.dart');
      final gen1 = p.join(tmp.path, 'a.g.dart');
      final gen2 = p.join(tmp.path, 'b.g.dart');
      await File(src).writeAsString('//');
      await File(gen1).writeAsString('//');
      await File(gen2).writeAsString('//');
      await Lang.DART.deleteAllGenFiles(tmp.path);
      expect(await File(src).exists(), isTrue);
      expect(await File(gen1).exists(), isFalse);
      expect(await File(gen2).exists(), isFalse);
    });
  });
}
