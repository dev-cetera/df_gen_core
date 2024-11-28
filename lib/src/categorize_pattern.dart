//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

final class CategorizedPattern<T> {
  //
  //
  //

  final String pattern;
  final T? category;

  //
  //
  //

  const CategorizedPattern({
    required this.pattern,
    this.category,
  });

  //
  //
  //

  RegExp get regExp => RegExp(this.pattern);

  //
  //
  //

  static T? categorize<T>(
    String value,
    Iterable<CategorizedPattern<T>> patterns,
  ) {
    for (final e in patterns) {
      final expression = RegExp(e.pattern, caseSensitive: false);
      if (expression.hasMatch(value)) {
        return e.category;
      }
    }
    return null;
  }

  //
  //
  //

  static bool matchesAny<T>(
    String value,
    Iterable<CategorizedPattern<T>> patterns,
  ) {
    if (patterns.isEmpty) {
      throw ArgumentError('patterns cannot be empty');
    }
    for (final pattern in patterns) {
      if (doesMatch(value, pattern)) {
        return true;
      }
    }
    return false;
  }

  static bool matchesAll<T>(
    String value,
    Iterable<CategorizedPattern<T>> patterns,
  ) {
    if (patterns.isEmpty) {
      throw ArgumentError('patterns cannot be empty');
    }
    for (final pattern in patterns) {
      if (!doesMatch(value, pattern)) {
        return false;
      }
    }
    return true;
  }

  static bool doesMatch<T>(
    String value,
    CategorizedPattern<T> pattern,
  ) {
    final expression = RegExp(pattern.pattern, caseSensitive: false);
    return expression.hasMatch(value);
  }

  //
  //
  //

  static const DEFAULT = _DefaulT.DEFAULT;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

enum _DefaulT {
  DEFAULT,
}
