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

import 'package:collection/collection.dart' show mergeSort;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Replaces the keys of [data] in [input] with the corresponding values.
///
/// The replacement is **single-pass**: every key is matched against the
/// original [input] only, never against a value that was substituted in. So
/// `replaceData('{a} {b}', {'{a}': '{b}', '{b}': 'X'})` gives `'{b} X'`, not
/// `'X X'`.
///
/// When the matches of two keys overlap, the key that comes first in [data]
/// wins and the later key only replaces matches that do not overlap one
/// already taken. Without overlaps this gives the same result as replacing
/// the keys one after another in the order of [data].
///
/// `null` values are skipped — they leave the matching pattern untouched in
/// [input] rather than substituting the literal string `"null"`. This means a
/// caller can defensively pass nullable values without having to filter the
/// map first.
String replaceData(String input, Map<Pattern, dynamic> data) {
  final taken = <_Replacement>[];
  for (final entry in data.entries) {
    final value = entry.value;
    if (value == null) continue;
    final text = value.toString();
    final found = entry.key
        .allMatches(input)
        .map((match) => _Replacement(match.start, match.end, text))
        .where((candidate) => !taken.any(candidate.overlaps));
    taken.addAll(found.toList());
  }
  // Sort by position. At one position a zero-width match (an insertion) goes
  // before a match that consumes text, and the stable sort keeps several
  // insertions there in key order.
  mergeSort(
    taken,
    compare: (a, b) {
      final byStart = a.start.compareTo(b.start);
      return byStart != 0 ? byStart : a.end.compareTo(b.end);
    },
  );
  final output = StringBuffer();
  var position = 0;
  for (final replacement in taken) {
    output.write(input.substring(position, replacement.start));
    output.write(replacement.text);
    position = replacement.end;
  }
  output.write(input.substring(position));
  return output.toString();
}

/// One match of a key in the original input, and the text that replaces it.
final class _Replacement {
  final int start;
  final int end;
  final String text;

  const _Replacement(this.start, this.end, this.text);

  bool overlaps(_Replacement other) => start < other.end && other.start < end;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension ReplaceDataOnStringX on String {
  /// Replaces the keys of [data] in this string with the corresponding values.
  String replaceData(Map<Pattern, dynamic> data) => _replaceData(this, data);
}

const _replaceData = replaceData;
