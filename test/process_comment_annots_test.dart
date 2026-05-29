import 'dart:io';

import 'package:df_gen_core/df_gen_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('df_gen_core_annots_');
  });

  tearDown(() async {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  Future<File> writeSource(String contents) async {
    final f = File(p.join(tmp.path, 'sample.dart'));
    await f.writeAsString(contents);
    return f;
  }

  test('invokes the registered callback for an annot line', () async {
    final f = await writeSource('''
// @hello
int x = 1;
''');
    var seen = false;
    await processCommentAnnots(
      filePath: f.path,
      onAnnotCallbacks: {
        'hello': (lineNumber, lines, filePath) async {
          seen = true;
          expect(lineNumber, 0);
          return true;
        },
      },
      annotsToDelete: const {},
    );
    expect(seen, isTrue);
  });

  test('unknown comment lines do not crash', () async {
    final f = await writeSource('''
// random
// another
void main() {}
''');
    // No matching callbacks; the function must complete without throwing.
    await processCommentAnnots(
      filePath: f.path,
      onAnnotCallbacks: const {},
      annotsToDelete: const {},
    );
  });

  test('annotsToDelete removes those annotated lines from the file', () async {
    // NOTE: the default commentAnnotPattern only captures [\w ]+, so the
    // annot name must not contain hyphens or other non-word chars.
    final f = await writeSource('''
// @delete_me
// some other line
int x = 1;
''');
    await processCommentAnnots(
      filePath: f.path,
      onAnnotCallbacks: const {},
      annotsToDelete: {'delete_me'},
    );
    final after = await f.readAsString();
    expect(after.contains('@delete_me'), isFalse);
    expect(after.contains('int x = 1'), isTrue);
  });

  test('callback returning false short-circuits the iteration', () async {
    final f = await writeSource('''
// @first
// @second
int x = 1;
''');
    final seen = <String>[];
    await processCommentAnnots(
      filePath: f.path,
      onAnnotCallbacks: {
        'first': (n, lines, fp) async {
          seen.add('first');
          return false; // stop
        },
        'second': (n, lines, fp) async {
          seen.add('second');
          return true;
        },
      },
      annotsToDelete: const {},
    );
    expect(seen, ['first']);
  });

  test('missing file does not throw', () async {
    await processCommentAnnots(
      filePath: p.join(tmp.path, 'no_such.dart'),
      onAnnotCallbacks: const {},
      annotsToDelete: const {},
    );
  });
}
