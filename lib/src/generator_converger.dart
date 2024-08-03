//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. SSee MIT LICENSE
// file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'insight_mapper.dart';
import 'replacement_producer.dart';
import 'replacements.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class GeneratorConverger<TInsight, TPlaceholder extends Enum, TFile> {
  //
  //
  //

  final Future<void> Function(
    Iterable<Replacements<TInsight>> insights,
    List<TFile> templates,
  ) _converge;

  //
  //
  //

  const GeneratorConverger(this._converge);

  //
  //
  //

  Future<void> Function(
    Iterable<TInsight> insights,
    List<TFile> templates,
    List<InsightMapper<TInsight, TPlaceholder>> insightMappers,
  ) get converge => (insights, templates, insightMappers) async {
        final produceReplacements =
            ReplacementProducer(() async => insightMappers).produceReplacements;
        final replacements = await Future.wait(
          insights.map(
            (a) {
              return produceReplacements(a).then((b) {
                return Replacements(
                  insight: a,
                  replacements: b,
                );
              });
            },
          ),
        );
        await this._converge(
          replacements,
          templates,
        );
      };
}
