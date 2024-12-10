import '../df_gen_core.dart';

class TemplateInterpolator<T> {
  final Map<String, String Function(T insight)> map;

  TemplateInterpolator(this.map);

  String interpolate(String template, T insight) {
    return template.replaceData(
      map.map((k, v) {
        return MapEntry(
          k,
          v(insight),
        );
      }),
    );
  }

  String interpolateAndJoin(
    String template,
    List<T> insights, {
    String separator = '\n',
  }) {
    return template.replaceData(
      map.map(
        (k, v) {
          return MapEntry(
            k,
            insights.map((e) {
              return v(e);
            }).join(separator),
          );
        },
      ),
    );
  }
}
