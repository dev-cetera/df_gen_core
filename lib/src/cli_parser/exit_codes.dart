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

export 'dart:io' show exit;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Represents standardized and custom exit codes for an application.
enum ExitCodes {
  // ---------------------------------------------------------------------------
  //
  // Standard exit codes.
  //
  // ---------------------------------------------------------------------------

  /// Successful execution.
  SUCCESS(0),

  /// General failure.
  FAILURE(1),

  // ---------------------------------------------------------------------------
  //
  // Specific exit codes.
  //
  // ---------------------------------------------------------------------------

  /// Command line usage error.
  USAGE(64),

  /// Data format error.
  DATA_ERR(65),

  /// Cannot open input.
  NO_INPUT(66),

  /// AddreSee unknown.
  NO_USER(67),

  /// Host name unknown.
  NO_HOST(68),

  /// Service unavailable.
  UNAVAILABLE(69),

  /// Internal software error.
  SOFTWARE(70),

  /// System error (e.g., cannot fork).
  OS_ERR(71),

  /// Critical OS file missing.
  OS_FILE(72),

  /// Can't create (user) output file.
  CANT_CREATE(73),

  /// Input/output error.
  IO_ERR(74),

  /// Temporary failure, retry later.
  TEMP_FAIL(75),

  /// Remote error in protocol.
  PROTOCOL(76),

  /// Permission denied.
  NO_PERM(77),

  /// Configuration error.
  CONFIG(78),

  // ---------------------------------------------------------------------------
  //
  // Custom application exit codes.
  //
  // ---------------------------------------------------------------------------

  /// Database connection failed.
  DB_CONN_FAILURE(100),

  /// API call failed.
  API_FAILURE(101),

  /// Authentication failure.
  AUTH_FAILURE(102),

  /// File not found.
  FILE_NOT_FOUND(103),

  /// Operation timed out.
  TIMEOUT(104),

  /// Unhandled exception occurred.
  UNHANDLED(105);

  /// Numeric value associated with the exit code.
  final int code;

  // ---------------------------------------------------------------------------

  /// Constructor for [ExitCodes] with the specified [code].
  const ExitCodes(this.code);
}
