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

import '/src/_index.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class ReplacementProducer<TInsight, TPlaceholder extends Enum> {
  //
  //
  //

  final Future<List<InsightMapper<TInsight, TPlaceholder>>> Function() _getMappers;

  //
  //
  //

  const ReplacementProducer(this._getMappers);

  //
  //
  //

  Future<Map<String, String>> Function(TInsight insight) get produceReplacements =>
      (insight) async {
        final mappers = await this._getMappers();
        final entries = await Future.wait(
          mappers.map(
            (e) async {
              return MapEntry(
                e.placeholder.placeholder,
                await e.mapInsights(insight),
              );
            },
          ),
        );
        return Map.fromEntries(entries);
      };
}
