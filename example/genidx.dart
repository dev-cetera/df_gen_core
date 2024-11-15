//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. SSee MIT LICENSE
// file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_config/df_config.dart' show ReplaceDataOnStringExtension;
import 'package:df_gen_core/df_gen_core.dart';
import 'package:df_log/df_log.dart';

import 'package:path/path.dart' as p;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

// [STEP 1] Define come constants to hold default argument values:
const _DEFAULT_TEMPLATE_PATH_OR_URL =
    'https://raw.githubusercontent.com/robmllze/df_generate_dart_indexes/main/templates/template.dart.md';
const _DEFAULT_INPUT_PATH = '.';
const _DEFAULT_OUTPUT_PATH = '{folder}.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main(List<String> args) async {
  // [STEP 2] Create an instance of the CliBuilder class to help us manage
  // our CLI application.
  final cliBuilder = CliParser(
    title: 'DFIDX',
    description:
        'A tool for generating index/barrel files for Dart. Ignores files that starts with underscores.',
    example: 'dfidx -i . -o _index.g.dart',
    params: [
      DefaultFlags.HELP.flag,
      DefaultOptions.INPUT_PATH.option.copyWith(defaultsTo: _DEFAULT_INPUT_PATH),
      DefaultOptions.TEMPLATE_PATH_OR_URL.option
          .copyWith(defaultsTo: _DEFAULT_TEMPLATE_PATH_OR_URL),
      DefaultOptions.OUTPUT_PATH.option.copyWith(defaultsTo: _DEFAULT_OUTPUT_PATH),
    ],
  );

  // [STEP 3] Parse our arguments.
  final (argResults, argParser) = cliBuilder.parse(args);

  // [STEP 4] Print help message if the user requests it, then exit.
  final help = argResults.flag(DefaultFlags.HELP.name);
  if (help) {
    printCyan(cliBuilder.getInfo(argParser));
    exit(EXIT_SUCCESS);
  }

  // [STEP 5] Extract all the arguments we need.
  String inputPath;
  String templatePathOrUrl;
  String outputFilePath;
  try {
    inputPath = argResults.option(DefaultOptions.INPUT_PATH.name)!;
    templatePathOrUrl = argResults.option(DefaultOptions.TEMPLATE_PATH_OR_URL.name)!;
    outputFilePath = argResults.option(DefaultOptions.OUTPUT_PATH.name)!;
  } catch (_) {
    printYellow('Missing required args! Use --help flag for more information.');
    exit(EXIT_FAILURE);
  }

  // [STEP 6] Decide on the output file path.
  outputFilePath = outputFilePath.replaceAll(
    '{folder}',
    PathUtility.i.folderName(p.join(getCurrentScriptDir(), outputFilePath)),
  );

  // [STEP 7] Create a stream to get all files ending in .dart but not in
  // .g.dart and do not start with underscores.
  final pathExplorerStream = PathExplorer(inputPath).exploreFiles();
  final exportableFilePathStream = pathExplorerStream.where((e) => _isPublicFileName(e.path));

  // [STEP 8] Create a replacement map for the template, to replace
  // placeholders in the template with the actual values. We also want to skip
  // the output file from being added to the exports file.
  final skipPath = p.relative(outputFilePath, from: inputPath);
  final exportableFilePaths = await exportableFilePathStream.toList();
  final replacementMap = {
    '___PUBLIC_EXPORTS___': _publicExports(
      inputPath,
      exportableFilePaths.map((e) => e.path).where((e) => e != skipPath),
      (e) => true,
      (e) => 'export \'./$e\';',
    ),
  };

  // [STEP 9] Read the template file.
  final result = await readTemplateFromPathOrUrl(templatePathOrUrl);
  if (result.isErr) {
    printYellow('Failed to read template at: $templatePathOrUrl');
    exit(EXIT_FAILURE);
  }

  // [STEP 10] Replace the placeholders in the template with the actual values.
  final output = result.unwrap().replaceData(replacementMap);

  // [STEP 11] Write the output file.
  try {
    await FileSystemUtility.i.writeLocalFile(outputFilePath, output);
  } catch (e) {
    printYellow('Failed to write at: $outputFilePath');
    exit(EXIT_FAILURE);
  }

  // [STEP 12] Print success!
  printGreen('Index/barrel file written at: $outputFilePath');
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String _publicExports(
  String inputPath,
  Iterable<String> filePaths,
  bool Function(String filePath) test,
  String Function(String baseName) statementBuilder,
) {
  final relativeFilePaths = filePaths.map((e) => p.relative(e, from: inputPath));
  final exportFilePaths = relativeFilePaths.where((e) => test(e));
  final statements = exportFilePaths.map(statementBuilder);
  return statements.join('\n');
}

bool _isPublicFileName(String e) {
  return !e.startsWith('_') &&
      !e.contains('${p.separator}_') &&
      !e.endsWith('.g.dart') &&
      e.endsWith('.dart');
}
