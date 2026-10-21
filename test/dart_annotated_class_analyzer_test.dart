import 'dart:io';

import 'package:df_gen_core/df_gen_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _source = '''
class Gen {
  const Gen({this.name});
  final String? name;
}

class Other {
  const Other.named();
}

const marker = Object();

@Gen(name: 'x')
class A {
  @Gen()
  final int f = 0;

  @Gen()
  void m() {}
}

@Other.named()
class B {}

@marker
class C {}
''';

void main() {
  late Directory tmp;
  late String filePath;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('df_gen_core_analyzer_');
    filePath = p.join(tmp.path, 'source.dart');
    await File(filePath).writeAsString(_source);
  });

  tearDownAll(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  DartAnnotatedClassAnalyzer analyzerFor() {
    return DartAnnotatedClassAnalyzer(
      filePath: filePath,
      analysisContextCollection: createDartAnalysisContextCollection(
        {tmp.path},
        null,
      ),
    );
  }

  test(
    'an unnamed-constructor annotation is matched by its class name '
    '(analyzer 14 reports its display name as `Gen.new`)',
    () async {
      final classes = <String>[];
      final classFields = <String, String?>{};
      final members = <String>[];
      final methods = <String>[];
      await analyzerFor().analyze(
        inclClassAnnotations: {'Gen'},
        inclMemberAnnotations: {'Gen'},
        inclMethodAnnotations: {'Gen'},
        onAnnotatedClass: (params) async {
          classes.add('${params.className}@${params.classAnnotationName}');
        },
        onClassAnnotationField: (params) async {
          classFields[params.fieldName] = params.fieldValue.toStringValue();
        },
        onAnnotatedMember: (params) async {
          members.add('${params.memberName}@${params.memberAnnotationName}');
        },
        onAnnotatedMethod: (params) async {
          methods.add('${params.methodName}@${params.methodAnnotationName}');
        },
      );
      expect(classes, ['A@Gen']);
      expect(classFields, {'name': 'x'});
      expect(members, ['f@Gen']);
      expect(methods, ['m@Gen']);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'named-constructor and constant annotations keep their names',
    () async {
      final classes = <String>[];
      await analyzerFor().analyze(
        onAnnotatedClass: (params) async {
          classes.add('${params.className}@${params.classAnnotationName}');
        },
      );
      expect(classes, ['A@Gen', 'B@Other.named', 'C@marker']);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
