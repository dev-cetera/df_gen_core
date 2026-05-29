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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Result of invoking an external tool (formatter, linter, etc.) via
/// [Process.run].
///
/// Captures both the case where the child process ran and returned an exit
/// code, and the case where the process could not be launched at all (e.g.,
/// the binary is not installed). [ok] is `true` only when the process ran
/// and exited with code `0`.
final class ProcessOutcome {
  /// `true` when the process ran and exited with code `0`.
  final bool ok;

  /// Exit code reported by the process, or `-1` if the process could not be
  /// launched.
  final int exitCode;

  /// Captured standard output.
  final String stdout;

  /// Captured standard error.
  final String stderr;

  /// Non-null when the process could not be launched (e.g., binary missing,
  /// invalid arguments rejected by the OS). Holds the underlying error text.
  final String? launchError;

  const ProcessOutcome({
    required this.ok,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    this.launchError,
  });

  /// Builds an outcome from a completed [ProcessResult].
  factory ProcessOutcome.fromResult(ProcessResult r) {
    return ProcessOutcome(
      ok: r.exitCode == 0,
      exitCode: r.exitCode,
      stdout: r.stdout.toString(),
      stderr: r.stderr.toString(),
    );
  }

  /// Builds an outcome representing a launch failure (the binary could not be
  /// run at all).
  factory ProcessOutcome.launchFailed(String reason) {
    return ProcessOutcome(
      ok: false,
      exitCode: -1,
      stdout: '',
      stderr: '',
      launchError: reason,
    );
  }

  /// Builds an outcome representing a precondition failure (e.g., the input
  /// file does not exist).
  factory ProcessOutcome.preconditionFailed(String reason) {
    return ProcessOutcome(
      ok: false,
      exitCode: -1,
      stdout: '',
      stderr: reason,
    );
  }

  /// A short, single-line summary suitable for logs. Includes the exit code
  /// and the first non-empty of [launchError]/[stderr]/[stdout].
  String summary() {
    if (launchError != null) {
      return 'launch failed: $launchError';
    }
    final tail = stderr.trim().isNotEmpty
        ? stderr.trim().split('\n').last
        : (stdout.trim().isNotEmpty ? stdout.trim().split('\n').last : '');
    return tail.isEmpty ? 'exit $exitCode' : 'exit $exitCode: $tail';
  }

  @override
  String toString() => 'ProcessOutcome(ok: $ok, ${summary()})';
}
