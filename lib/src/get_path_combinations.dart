//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_collection/df_collection.dart';
import 'package:equatable/equatable.dart';

import 'package:path/path.dart' as p;

import 'utilities/path_utility.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class GetPathCombinations extends Equatable {
  //
  //
  //

  final Set<String> _value;

  //
  //
  //

  GetPathCombinations(
    List<Set<String>> pathSets, {
    Set<String> pathPatterns = const {},
  }) : _value = _generateValue(pathSets, pathPatterns);

  //
  //
  //

  Set<String> call() => _value;

  //
  //
  //

  static Set<String> _generateValue(
    List<Set<String>> pathSets,
    Set<String> pathPatterns,
  ) {
    return powerset(pathSets, (a, b) => p.normalize(p.join(a, b)))
        .map((e) => matchesAnyPathPattern(e, pathPatterns) ? e : null)
        .whereType<String>()
        .toSet();
  }

  //
  //
  //

  @override
  List<Object?> get props => _value.toList();
}
