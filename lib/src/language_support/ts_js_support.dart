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

import 'package:df_log/df_log.dart';

import 'process_outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Formats the TypeScript/JavaScript file at [filePath] via `prettier --write`.
///
/// Returns a [ProcessOutcome] capturing the exit code and any stderr output.
/// `ok` is `false` if the file does not exist, prettier cannot be launched,
/// or it exits non-zero.
Future<ProcessOutcome> fmtTsJsFile(String filePath) async {
  if (!await File(filePath).exists()) {
    Log.printRed('TS/JS file not found: $filePath');
    return ProcessOutcome.preconditionFailed('file not found: $filePath');
  }
  final ProcessResult result;
  try {
    result = await Process.run('prettier', ['--write', filePath]);
  } catch (e) {
    Log.printRed('Could not run "prettier" on $filePath: $e');
    return ProcessOutcome.launchFailed('$e');
  }
  final outcome = ProcessOutcome.fromResult(result);
  if (!outcome.ok) {
    Log.printRed('prettier failed for $filePath (${outcome.summary()})');
  }
  return outcome;
}

/// Fixes the TypeScript/JavaScript file at [filePath] via `eslint --fix`.
///
/// Returns a [ProcessOutcome] capturing the exit code and any stderr output.
/// `ok` is `false` if the file does not exist, eslint cannot be launched, or
/// it exits non-zero.
Future<ProcessOutcome> fixTsJsFile(String filePath) async {
  if (!await File(filePath).exists()) {
    Log.printRed('TS/JS file not found: $filePath');
    return ProcessOutcome.preconditionFailed('file not found: $filePath');
  }
  final ProcessResult result;
  try {
    result = await Process.run('eslint', ['--fix', filePath]);
  } catch (e) {
    Log.printRed('Could not run "eslint" on $filePath: $e');
    return ProcessOutcome.launchFailed('$e');
  }
  final outcome = ProcessOutcome.fromResult(result);
  if (!outcome.ok) {
    Log.printRed('eslint failed for $filePath (${outcome.summary()})');
  }
  return outcome;
}
