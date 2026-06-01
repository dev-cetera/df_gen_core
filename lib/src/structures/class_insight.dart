//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

class ClassInsight<TAnnotation> {
  //
  //
  //

  final TAnnotation annotation;
  final String className;
  final String dirPath;
  final String fileName;

  /// Display name of the annotated abstract class's direct supertype, if
  /// the extractor was able to determine it (e.g. `Model`, `BaseModel`,
  /// or a user-defined base). `null` when unknown. Used by the generator
  /// to decide inheritance-driven behaviours (e.g. whether to mix in
  /// EquatableMixin — classes that extend BaseModel skip it because
  /// their instances may appear in const Sets).
  final String? supertypeName;

  //
  //
  //

  const ClassInsight({
    required this.annotation,
    required this.className,
    required this.dirPath,
    required this.fileName,
    this.supertypeName,
  });
}
