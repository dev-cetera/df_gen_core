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

import '../path_explorer.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class FileInsight {
  //
  //
  //

  final FilePathExplorerFinding filePathFinding;

  //
  //
  //

  const FileInsight({
    required this.filePathFinding,
  });
}

sealed class PerIntersection<T> {
  //
  //
  //

  final String sourceTemplatePathOrUrl;
  final Map<String, dynamic> replacements;
  final T? category;

  //
  //
  //

  const PerIntersection({
    required this.sourceTemplatePathOrUrl,
    required this.replacements,
    this.category,
  });
}

final class PerFolderIntersection<T> extends PerIntersection<T> {
  //
  //
  //

  final FilePathExplorerFinding sourceFolderPathOrUrl;

  //
  //
  //

  const PerFolderIntersection({
    required this.sourceFolderPathOrUrl,
    required super.sourceTemplatePathOrUrl,
    required super.replacements,
    super.category,
  });
}

final class PerFileIntersection<T> extends PerIntersection<T> {
  //
  //
  //

  final String sourceFilePathOrUrl;

  //
  //
  //

  const PerFileIntersection({
    required this.sourceFilePathOrUrl,
    required super.sourceTemplatePathOrUrl,
    required super.replacements,
    super.category,
  });
}

final class PerFileListIntersection<T> extends PerIntersection<T> {
  //
  //
  //

  final Iterable<String> sourceFilePathOrUrlList;

  //
  //
  //

  const PerFileListIntersection({
    required this.sourceFilePathOrUrlList,
    required super.sourceTemplatePathOrUrl,
    required super.replacements,
    super.category,
  });
}

final class PerFolderListIntersection<T> extends PerIntersection<T> {
  //
  //
  //

  final Iterable<String> sourceFolderPathOrUrlList;

  //
  //
  //

  const PerFolderListIntersection({
    required this.sourceFolderPathOrUrlList,
    required super.sourceTemplatePathOrUrl,
    required super.replacements,
    super.category,
  });
}
