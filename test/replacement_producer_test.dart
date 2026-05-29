import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

enum _Tag { ONE, TWO }

void main() {
  test(
      'produceReplacements collects per-insight values keyed by enum placeholder',
      () async {
    final producer = ReplacementProducer<String, _Tag>(
      () async => [
        InsightMapper(
          placeholder: _Tag.ONE,
          mapInsights: (i) async => 'A:$i',
        ),
        InsightMapper(
          placeholder: _Tag.TWO,
          mapInsights: (i) async => 'B:$i',
        ),
      ],
    );

    final r = await producer.produceReplacements('x');
    expect(r['___ONE___'], 'A:x');
    expect(r['___TWO___'], 'B:x');
  });
}
