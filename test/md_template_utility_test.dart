import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('MdTemplateUtility.extractCodeSnippetsFromMarkdown', () {
    test('returns all code blocks regardless of language', () {
      const md = '''
Intro.

```dart
final a = 1;
```

Some text.

```ts
const b = 2;
```
''';
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(md);
      expect(snippets, ['final a = 1;', 'const b = 2;']);
    });

    test('filters by langCode when supplied', () {
      const md = '''
```dart
final a = 1;
```

```ts
const b = 2;
```
''';
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(
        md,
        langCode: 'dart',
      );
      expect(snippets, ['final a = 1;']);
    });

    test('returns empty list for markdown with no fenced code', () {
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(
        'plain text',
      );
      expect(snippets, isEmpty);
    });

    test('handles multi-line code blocks', () {
      const md = '''
```dart
final a = 1;
final b = 2;
final c = 3;
```
''';
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(md);
      expect(snippets, ['final a = 1;\nfinal b = 2;\nfinal c = 3;']);
    });

    test('inline triple backticks on a single line are not treated as a fence',
        () {
      // Regression: before the line-start anchor fix, this single line of
      // narrative would have been parsed as if it contained code blocks.
      const md =
          'See the example using ```final a = 1;``` inline and explain it.';
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(md);
      expect(snippets, isEmpty);
    });

    test('fence at start of file (no preceding newline) is still matched', () {
      const md = '''```dart
final a = 1;
```''';
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(md);
      expect(snippets, ['final a = 1;']);
    });

    test('indented fences are still recognized', () {
      const md = '''
Intro.

  ```dart
  final a = 1;
  ```
''';
      final snippets = MdTemplateUtility.i.extractCodeSnippetsFromMarkdown(md);
      expect(snippets, hasLength(1));
      expect(snippets.first, contains('final a = 1;'));
    });
  });

  group('MdTemplateUtility.extractCodeFromMarkdown', () {
    test('joins all snippets with newlines', () {
      const md = '''
```dart
final a = 1;
```

```dart
final b = 2;
```
''';
      final code = MdTemplateUtility.i.extractCodeFromMarkdown(md);
      expect(code, 'final a = 1;\nfinal b = 2;');
    });
  });
}
