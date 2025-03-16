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

// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:df_config/src/_etc/replace_data.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class TemplateInterpolator<T> {
  final Map<String, String Function(T insight)> map;

  TemplateInterpolator(this.map);

  String interpolate(String template, T insight) {
    return template.replaceData(
      map.map((k, v) {
        return MapEntry(k, v(insight));
      }),
    );
  }

  String interpolateAndJoin(
    String template,
    List<T> insights, {
    String separator = '\n',
  }) {
    return template.replaceData(
      map.map((k, v) {
        return MapEntry(
          k,
          insights
              .map((e) {
                return v(e);
              })
              .join(separator),
        );
      }),
    );
  }
}
