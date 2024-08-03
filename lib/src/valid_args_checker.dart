//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. SSee MIT LICENSE
// file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:meta/meta.dart' show nonVirtual;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Provides a mechanism to check if command line args are valid or not.
abstract class ValidArgsChecker {
  //
  //
  //

  const ValidArgsChecker();

  //
  //
  //

  /// The list of arguments to consider for validation.
  List<dynamic> get args;

  //
  //
  //

  /// Returns true if every element in [args] is neither `null` nor empty.
  /// If an argument does not have an `isEmpty` method, it is assumed to be not
  /// empty.
  @nonVirtual
  bool get isValid {
    for (final arg in this.args) {
      if (arg == null) {
        return false;
      }
      try {
        // Check if the argument is empty; if it is, return false. Otherwise, if
        // isEmpty is not a valid method, continue.
        if (arg.isEmpty) {
          return false;
        }
      } catch (_) {
        continue;
      }
    }
    return true;
  }
}
