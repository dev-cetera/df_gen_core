import 'dart:io';

import 'package:df_gen_core/df_gen_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FileSystemUtility.i — file I/O', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('df_gen_core_fs_');
    });

    tearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    test('writeLocalFile then readLocalFileOrNull round-trips content',
        () async {
      final path = p.join(tmp.path, 'a', 'b.txt');
      await FileSystemUtility.i.writeLocalFile(path, 'hello');
      final r = await FileSystemUtility.i.readLocalFileOrNull(path);
      expect(r, 'hello');
    });

    test('writeLocalFile with append=true appends', () async {
      final path = p.join(tmp.path, 'log.txt');
      await FileSystemUtility.i.writeLocalFile(path, 'a');
      await FileSystemUtility.i.writeLocalFile(path, 'b', append: true);
      final r = await FileSystemUtility.i.readLocalFileOrNull(path);
      expect(r, 'ab');
    });

    test('readLocalFileOrNull returns null for missing file', () async {
      final r = await FileSystemUtility.i.readLocalFileOrNull(
        p.join(tmp.path, 'missing.txt'),
      );
      expect(r, isNull);
    });

    test('readLocalFileAsLinesOrNull splits on newlines', () async {
      final path = p.join(tmp.path, 'lines.txt');
      await FileSystemUtility.i.writeLocalFile(path, 'one\ntwo\nthree');
      final r = await FileSystemUtility.i.readLocalFileAsLinesOrNull(path);
      expect(r, ['one', 'two', 'three']);
    });

    test('clearLocalFile empties the file', () async {
      final path = p.join(tmp.path, 'x.txt');
      await FileSystemUtility.i.writeLocalFile(path, 'data');
      await FileSystemUtility.i.clearLocalFile(path);
      final r = await FileSystemUtility.i.readLocalFileOrNull(path);
      expect(r, '');
    });

    test('localFileExists returns true/false correctly', () async {
      final path = p.join(tmp.path, 'present.txt');
      expect(await FileSystemUtility.i.localFileExists(path), isFalse);
      await FileSystemUtility.i.writeLocalFile(path, 'x');
      expect(await FileSystemUtility.i.localFileExists(path), isTrue);
    });

    test('deleteLocalFile removes the file', () async {
      final path = p.join(tmp.path, 'gone.txt');
      await FileSystemUtility.i.writeLocalFile(path, 'x');
      await FileSystemUtility.i.deleteLocalFile(path);
      expect(await FileSystemUtility.i.localFileExists(path), isFalse);
    });

    test('listLocalFilePaths returns files (recursive default)', () async {
      await FileSystemUtility.i.writeLocalFile(p.join(tmp.path, 'a.txt'), 'a');
      await FileSystemUtility.i
          .writeLocalFile(p.join(tmp.path, 'sub', 'b.txt'), 'b');
      final r = await FileSystemUtility.i.listLocalFilePaths(tmp.path);
      expect(r, isNotNull);
      expect(r!.length, 2);
    });

    test('listLocalFilePaths returns null for missing dir', () async {
      final r = await FileSystemUtility.i.listLocalFilePaths(
        p.join(tmp.path, 'no_such_dir'),
      );
      expect(r, isNull);
    });

    test('findLocalFileByNameOrNull walks subdirs', () async {
      await FileSystemUtility.i.writeLocalFile(
        p.join(tmp.path, 'sub', 'deep', 'target.txt'),
        'hit',
      );
      final r = await FileSystemUtility.i.findLocalFileByNameOrNull(
        'target.txt',
        tmp.path,
      );
      expect(r, isNotNull);
      expect(p.basename(r!.path), 'target.txt');
    });

    test('findFilePaths filters by onFilePathFound predicate', () async {
      await FileSystemUtility.i.writeLocalFile(p.join(tmp.path, 'a.txt'), '1');
      await FileSystemUtility.i.writeLocalFile(p.join(tmp.path, 'b.go'), '1');
      final r = await FileSystemUtility.i.findFilePaths(
        tmp.path,
        onFilePathFound: (path) => path.endsWith('.txt'),
      );
      expect(r.length, 1);
      expect(r.first, endsWith('.txt'));
    });
  });

  group('FileSystemUtility.i.extractTopmostDirPaths (bug-fix regression test)',
      () {
    test('keeps only the topmost dir when nested', () {
      final r = FileSystemUtility.i.extractTopmostDirPaths<String>(
        ['/repo/a', '/repo/a/sub', '/repo/a/sub/deeper', '/repo/b'],
        toPath: (e) => e,
      );
      expect(r.length, 2);
      expect(r, containsAll(['/repo/a', '/repo/b']));
    });

    test('handles paths regardless of separator (cross-platform fix)', () {
      // The pre-fix code compared with hardcoded `/`. Verify that
      // normalized paths are handled.
      final r = FileSystemUtility.i.extractTopmostDirPaths<String>(
        ['lib/src', 'lib/src/inner', 'lib/test'],
        toPath: (e) => e,
      );
      expect(r.length, 2);
      expect(r, containsAll(['lib/src', 'lib/test']));
    });

    test('duplicate paths are kept only once', () {
      final r = FileSystemUtility.i.extractTopmostDirPaths<String>(
        ['/a', '/a', '/a/sub'],
        toPath: (e) => e,
      );
      expect(r.length, 1);
      expect(r.first, '/a');
    });

    test('empty input returns empty output', () {
      final r = FileSystemUtility.i.extractTopmostDirPaths<String>(
        const <String>[],
        toPath: (e) => e,
      );
      expect(r, isEmpty);
    });
  });
}
