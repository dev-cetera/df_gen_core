//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:df_log/df_log.dart';
import 'package:path/path.dart' as p;

import 'process_outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Formats the Dart file at [filePath] via `dart format`.
///
/// Returns a [ProcessOutcome] capturing the exit code and any stderr output.
/// `ok` is `false` if the file does not exist, the `dart` binary cannot be
/// launched, or `dart format` exits non-zero.
Future<ProcessOutcome> fmtDartFile(String filePath) async {
  if (!await File(filePath).exists()) {
    Log.printRed('Dart file not found: $filePath');
    return ProcessOutcome.preconditionFailed('file not found: $filePath');
  }
  final ProcessResult result;
  try {
    result = await Process.run('dart', ['format', filePath]);
  } catch (e) {
    Log.printRed('Could not run "dart format" on $filePath: $e');
    return ProcessOutcome.launchFailed('$e');
  }
  final outcome = ProcessOutcome.fromResult(result);
  if (!outcome.ok) {
    Log.printRed('dart format failed for $filePath (${outcome.summary()})');
  }
  return outcome;
}

/// Applies `dart fix --apply` to the Dart file at [filePath].
///
/// Returns a [ProcessOutcome] capturing the exit code and any stderr output.
/// `ok` is `false` if the file does not exist, the `dart` binary cannot be
/// launched, or `dart fix` exits non-zero.
Future<ProcessOutcome> fixDartFile(String filePath) async {
  if (!await File(filePath).exists()) {
    Log.printRed('Dart file not found: $filePath');
    return ProcessOutcome.preconditionFailed('file not found: $filePath');
  }
  final ProcessResult result;
  try {
    result = await Process.run('dart', ['fix', '--apply', filePath]);
  } catch (e) {
    Log.printRed('Could not run "dart fix" on $filePath: $e');
    return ProcessOutcome.launchFailed('$e');
  }
  final outcome = ProcessOutcome.fromResult(result);
  if (!outcome.ok) {
    Log.printRed('dart fix failed for $filePath (${outcome.summary()})');
  }
  return outcome;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Creates an [AnalysisContextCollection] from a set of [paths]. This is used
/// to analyze Dart files.
///
/// The [fallbackDartSdkPath] is used if the `DART_SDK` environment variable is
/// not set.
AnalysisContextCollection createDartAnalysisContextCollection(
  Iterable<String> paths,
  String? fallbackDartSdkPath,
) {
  final sdkPath = Platform.environment['DART_SDK'] ?? fallbackDartSdkPath;
  final includePaths =
      paths.toSet().map((e) => p.normalize(p.absolute(e))).toList();
  final collection = AnalysisContextCollection(
    includedPaths: includePaths,
    resourceProvider: PhysicalResourceProvider.INSTANCE,
    sdkPath: sdkPath,
  );
  return collection;
}
