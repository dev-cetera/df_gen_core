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

import 'package:df_safer_dart/df_safer_dart.dart';
import '/df_gen_core.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class MdTemplateUtility {
  static const i = MdTemplateUtility._();

  const MdTemplateUtility._();

  Async<String> readTemplateFromPathOrUrl(String templatePathOrUrl) {
    return FileSystemUtility.i
        .readFileFromPathOrUrl(templatePathOrUrl)
        .map((e) => extractCodeFromMarkdown(e));
  }

  /// Extracts all code for the language [langCode] from some Markdown [content].
  String extractCodeFromMarkdown(
    String content, {
    String? langCode,
  }) {
    final snippets = extractCodeSnippetsFromMarkdown(
      content,
      langCode: langCode,
    );
    final code = snippets.join('\n');
    return code;
  }

  /// Extracts all code snippets for the language [langCode] from some Markdown [content].
  List<String> extractCodeSnippetsFromMarkdown(
    String content, {
    String? langCode,
  }) {
    final dartCodeRegex =
        RegExp('```(${langCode ?? '[^\\n]*'})\\n(.*?)```', dotAll: true);
    final matches = dartCodeRegex.allMatches(content);
    final snippets = matches.map((e) => e.group(2)?.trim() ?? '').toList();
    return snippets;
  }
}
