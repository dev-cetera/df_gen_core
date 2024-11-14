//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. SSee MIT LICENSE
// file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:io';

import 'package:df_config/df_config.dart';
import 'package:df_gen_core/df_gen_core.dart';
import 'package:df_log/df_log.dart';

import 'package:path/path.dart' as p;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

const DEFAULT_TEMPLATE_PATH_OR_URL =
    'https://raw.githubusercontent.com/robmllze/df_generate_dart_indexes/main/templates/template.dart.md';

const DEFAULT_INPUT_PATH = '.';

const DEFAULT_OUTPUT_PATH = '_index.g.dart';

const EXIT_SUCCESS = 0;
const EXIT_FAILURE = 1;

void main(List<String> args) async {
  // Step 1: Get input.
  final cliBuilder = CliBuilder(
    title: '',
    description: '',
    params: [
      DefaultFlags.HELP.flag,
      DefaultOptions.INPUT_PATH.option.copyWith(defaultsTo: DEFAULT_INPUT_PATH),
      DefaultOptions.TEMPLATE_PATH_OR_URL.option.copyWith(defaultsTo: DEFAULT_TEMPLATE_PATH_OR_URL),
      DefaultOptions.OUTPUT_PATH.option.copyWith(defaultsTo: DEFAULT_OUTPUT_PATH),
    ],
  );
  final r = cliBuilder.build(args);
  final parser = r.argParser;
  final results = r.argResults;

  bool help;
  String inputPath;
  String templatePathOrUrl;
  String outputPath;

  try {
    help = results.flag(DefaultFlags.HELP.name);
    if (help) {
      printWhite(parser.usage);
      exit(EXIT_SUCCESS);
    }
    inputPath = results.option(DefaultOptions.INPUT_PATH.name)!;
    templatePathOrUrl = results.option(DefaultOptions.TEMPLATE_PATH_OR_URL.name)!;
    outputPath = results.option(DefaultOptions.OUTPUT_PATH.name)!;
  } catch (_) {
    printYellow('Missing required args! Use --help flag for more information.');
    exit(EXIT_FAILURE);
  }

  // Step 2: Iterate through input files, and create intersections.

  final pathExplorer = PathExplorer(
    combinations: {
      GetPathCombinations([
        {inputPath},
      ]),
    },
  );

  final findings =
      pathExplorer.explore().where((e) => e is FilePathExplorerFinding && e.path.endsWith('.dart'));

  final test = await pathExplorer.explore().firstWhere((e) => e is DirPathExplorerFinding)
      as DirPathExplorerFinding;


  // printRed(await test.files.toList());

  final filePaths1 = await findings.toList();

  printRed(filePaths1.map((e) => e.path).join('\n'));

  final intersection = PerFileListIntersection<void>(
    sourceFilePathOrUrlList: filePaths1.map((e) => e.path),
    sourceTemplatePathOrUrl: templatePathOrUrl,
    replacements: {
      '___PUBLIC_EXPORTS___': publicExports(
        inputPath,
        filePaths1.map((e) => e.path),
        (e) => true,
        (e) => 'export \'$e\';',
      )
    },
  );

  // Step 3: Load templates or additional info.

  final result = await IoUtility.i.readFileFromPathOrUrl(templatePathOrUrl);
  if (result.isErr) {
    printYellow('Failed to read template at "$templatePathOrUrl"');
    exit(EXIT_FAILURE);
  }
  final template = extractCodeFromMarkdown(result.unwrap(), langCode: Lang.DART.code);
  final output = template.replaceData(intersection.replacements);

  printRed(output);

  // Step 4: Combine insights, templates and additional info into outputs.
}

String publicExports(
  String rootDirPath,
  Iterable<String> filePaths,
  bool Function(String filePath) test,
  String Function(String baseName) statementBuilder,
) {
  final relativeFilePaths = filePaths.map((e) => p.relative(e, from: rootDirPath));
  final exportFilePaths = relativeFilePaths.where((e) => test(e));
  final statements = exportFilePaths.map(statementBuilder);
  return statements.join('\n');
}

bool _isDartFileName(String e) {
  return !e.startsWith('_') &&
      !e.contains('${p.separator}_') &&
      !e.endsWith('.g.dart') &&
      e.endsWith('.dart');
}
