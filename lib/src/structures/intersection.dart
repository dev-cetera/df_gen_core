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

class Intersection<TInsight> {
  //
  //
  //

  final TInsight insight;
  final Map<String, dynamic> replacements;

  //
  //
  //

  const Intersection({
    required this.insight,
    required this.replacements,
  });

  //
  //
  //

  /// Generates replacements with a static map for all insights.
  static TIntersection<T> generateWithStatic<T>(
    Iterable<T> insights,
    Map<String, dynamic> staticReplacements,
  ) {
    return insights.map(
      (insight) => Intersection(
        insight: insight,
        replacements: staticReplacements,
      ),
    );
  }

  /// Generates replacements with dynamic replacements for each insight.
  static TIntersection<T> generateWithDynamic<T>(
    Iterable<T> insights,
    Map<String, dynamic> Function(T insight) dynamicReplacements,
  ) {
    return insights.map(
      (insight) => Intersection(
        insight: insight,
        replacements: dynamicReplacements(insight),
      ),
    );
  }

  /// Generates replacements for multiple insights with a shared static map.
  static TIntersection<T> generateMultiWithStatic<T>(
    Iterable<T> insights,
    Map<String, dynamic> staticReplacements,
  ) sync* {
    for (var insight in insights) {
      yield Intersection<T>(
        insight: insight,
        replacements: staticReplacements,
      );
    }
  }

  /// Generates replacements for multiple insights with dynamic replacements per insight.
  static TIntersection<T> generateMultiWithDynamic<T>(
    Iterable<T> insights,
    Map<String, dynamic> Function(T insight) dynamicReplacements,
  ) sync* {
    for (var insight in insights) {
      yield Intersection<T>(
        insight: insight,
        replacements: dynamicReplacements(insight),
      );
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TIntersection<T> = Iterable<Intersection<T>>;
