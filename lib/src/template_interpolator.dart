import '../df_gen_core.dart';

class TemplateInterpolator<T> {
  final Map<String, String Function(T insight)> map;

  TemplateInterpolator(this.map);

  String interpolate(String template, T insight) {
    return template.replaceData(
      map.map((k, v) => MapEntry(k, v(insight))),
    );
  }
}
