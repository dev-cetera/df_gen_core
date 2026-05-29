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
import 'package:path/path.dart' as p;

import 'process_outcome.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Formats the Rust file at [filePath] via the `rustfmt` command.
///
/// Returns a [ProcessOutcome] capturing the exit code and any stderr output.
/// `ok` is `false` if the file does not exist, `rustfmt` cannot be launched,
/// or it exits non-zero.
Future<ProcessOutcome> fmtRustFile(String filePath) async {
  if (!await File(filePath).exists()) {
    Log.printRed('Rust file not found: $filePath');
    return ProcessOutcome.preconditionFailed('file not found: $filePath');
  }
  final ProcessResult result;
  try {
    result = await Process.run('rustfmt', [filePath]);
  } catch (e) {
    Log.printRed('Could not run "rustfmt" on $filePath: $e');
    return ProcessOutcome.launchFailed('$e');
  }
  final outcome = ProcessOutcome.fromResult(result);
  if (!outcome.ok) {
    Log.printRed('rustfmt failed for $filePath (${outcome.summary()})');
  }
  return outcome;
}

/// Runs `cargo fix` on the Cargo project that owns the file at [filePath].
///
/// `cargo fix` operates on a Cargo workspace, not on individual files: it
/// walks up from its working directory looking for `Cargo.toml`. This
/// function therefore sets the working directory to the parent of [filePath]
/// and lets cargo locate the manifest. If no `Cargo.toml` is found anywhere
/// in the ancestor chain, the outcome reports a precondition failure.
///
/// `--allow-dirty --allow-staged` are passed so cargo does not refuse to run
/// when the file is part of a working tree with uncommitted changes — a
/// generator's output almost always falls in that case.
///
/// Returns a [ProcessOutcome] capturing the exit code and any stderr output.
Future<ProcessOutcome> fixRustFile(String filePath) async {
  if (!await File(filePath).exists()) {
    Log.printRed('Rust file not found: $filePath');
    return ProcessOutcome.preconditionFailed('file not found: $filePath');
  }
  final manifestDir = await _findCargoManifestDir(filePath);
  if (manifestDir == null) {
    final msg = 'No Cargo.toml found in any ancestor of $filePath';
    Log.printRed(msg);
    return ProcessOutcome.preconditionFailed(msg);
  }
  final ProcessResult result;
  try {
    result = await Process.run(
      'cargo',
      ['fix', '--allow-dirty', '--allow-staged'],
      workingDirectory: manifestDir,
    );
  } catch (e) {
    Log.printRed('Could not run "cargo fix" in $manifestDir: $e');
    return ProcessOutcome.launchFailed('$e');
  }
  final outcome = ProcessOutcome.fromResult(result);
  if (!outcome.ok) {
    Log.printRed('cargo fix failed in $manifestDir (${outcome.summary()})');
  }
  return outcome;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<String?> _findCargoManifestDir(String filePath) async {
  var dir = Directory(p.dirname(p.absolute(filePath)));
  while (true) {
    if (await File(p.join(dir.path, 'Cargo.toml')).exists()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}
