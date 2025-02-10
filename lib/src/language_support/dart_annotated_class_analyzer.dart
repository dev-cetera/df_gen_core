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

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:df_collection/df_collection.dart';
import 'package:path/path.dart' as p;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Provides a mechanism to analyze Dart classes from a file path.
final class DartAnnotatedClassAnalyzer {
  //
  //
  //

  final String filePath;
  final dynamic analysisContextCollection;

  //
  //
  //

  const DartAnnotatedClassAnalyzer({
    required this.filePath,
    required this.analysisContextCollection,
  }) : assert(analysisContextCollection is AnalysisContextCollection);

  //
  //
  //

  /// Analyzes the Dart file at [filePath] via [analysisContextCollection].
  ///
  /// This method triggers callbacks when encountering annotated classes, methods, or members.
  /// - [classNameFilter] Includes classes whose names match this regular expression, if specified.
  /// - [methodNameFilter] Includes methods whose names match this regular expression, if specified.
  /// - [memberNameFilter] Includes members whose names match this regular expression, if specified.
  /// - [inclClassAnnotations] Targets classes with these annotations for analysis.
  /// - [inclMethodAnnotations] Targets methods with these annotations for analysis.
  /// - [inclMemberAnnotations] Targets members with these annotations for analysis.
  /// - [onAnnotatedClass] Invoked for each class matching [inclClassAnnotations].
  /// - [onClassAnnotationField] Invoked for each field in an annotated class.
  /// - [onAnnotatedMethod] Invoked for each method matching [inclMethodAnnotations].
  /// - [onMethodAnnotationField] Invoked for fields in an annotated method.
  /// - [onAnnotatedMember] Invoked for each member matching [inclMemberAnnotations].
  /// - [onMemberAnnotationField] Invoked for fields in an annotated member.
  /// - [onPreAnalysis] Invoked before analyzing a class.
  /// - [onPostAnalysis] Invoked after analyzing a class.
  Future<void> analyze({
    RegExp? classNameFilter,
    RegExp? methodNameFilter,
    RegExp? memberNameFilter,
    Set<String>? inclClassAnnotations,
    Set<String>? inclMethodAnnotations,
    Set<String>? inclMemberAnnotations,
    TOnAnnotatedClassCallback? onAnnotatedClass,
    TOnClassAnnotationFieldCallback? onClassAnnotationField,
    TOnAnnotatedMethodCallback? onAnnotatedMethod,
    TOnMethodAnnotationFieldCallback? onMethodAnnotationField,
    TOnAnnotatedMemberCallback? onAnnotatedMember,
    TOnMemberAnnotationFieldsCallback? onMemberAnnotationField,
    TOnPreAnalysis? onPreAnalysis,
    TOnPostAnalysis? onPostAnalysis,
  }) async {
    final fullFilePath = p.normalize(p.absolute(filePath));
    final fullFileUri = Uri.file(fullFilePath);
    final context = analysisContextCollection.contextFor(fullFilePath);
    final library = await context.currentSession.getLibraryByUri(fullFileUri.toString());
    if (library is LibraryElementResult) {
      final classElements = library.element.topLevelElements.whereType<ClassElement>();
      for (final classElement in classElements) {
        final className = classElement.displayName;
        if (classNameFilter == null || classNameFilter.hasMatch(className)) {
          onPreAnalysis?.call(
            fullFilePath,
            className,
          );
          await _processMemberAnnotations(
            fullFilePath,
            classElement,
            memberNameFilter,
            onAnnotatedMember,
            onMemberAnnotationField,
            inclMemberAnnotations,
          );
          await _processMethodAnnotations(
            fullFilePath,
            classElement,
            methodNameFilter,
            onAnnotatedMethod,
            onMethodAnnotationField,
            inclMethodAnnotations,
          );
          final params = <OnAnnotatedClassParams>[];
          await _processClassAnnotations(
            fullFilePath,
            classElement,
            (p) async {
              params.add(p);
              await onAnnotatedClass?.call(p);
            },
            onClassAnnotationField,
            inclClassAnnotations,
          );
          if (onPostAnalysis != null) {
            for (final p in params) {
              onPostAnalysis(p);
            }
          }
        }
      }
    }
  }

  //
  //
  //

  Future<void> _processMemberAnnotations(
    String fullFilePath,
    ClassElement classElement,
    RegExp? memberNameFilter,
    TOnAnnotatedMemberCallback? onAnnotatedMember,
    TOnMemberAnnotationFieldsCallback? onMemberAnnotationField,
    Set<String>? inclMemberAnnotations,
  ) async {
    for (final fieldElement in classElement.fields) {
      if (memberNameFilter == null || memberNameFilter.hasMatch(fieldElement.displayName)) {
        for (final fieldMetadata in fieldElement.metadata) {
          final memberAnnotationName = fieldMetadata.element?.displayName;
          if (memberAnnotationName != null &&
              inclMemberAnnotations?.contains(memberAnnotationName) != false) {
            final fieldElements = fieldMetadata.element;
            final fieldNames = fieldElements?.children.map((e) => e.displayName);
            var memberAnnotationFields = <String, DartObject>{};
            if (fieldNames != null) {
              memberAnnotationFields = Map.fromEntries(
                fieldNames.map((e) {
                  return MapEntry(
                    e,
                    fieldMetadata.computeConstantValue()?.getField(e),
                  );
                }),
              ).nonNulls;
            }
            final parent = OnAnnotatedMemberParams(
              fullFilePath: fullFilePath,
              memberAnnotationName: memberAnnotationName,
              memberAnnotationFields: memberAnnotationFields,
              memberName: fieldElement.displayName,
              memberType: fieldElement.type,
            );
            final stick = await onAnnotatedMember?.call(parent);
            for (final e in memberAnnotationFields.entries) {
              final fieldName = e.key;
              final fieldValue = e.value;
              await onMemberAnnotationField?.call(
                OnMemberAnnotationFieldParams(
                  parent: parent,
                  stick: stick,
                  fullFilePath: fullFilePath,
                  fieldName: fieldName,
                  fieldValue: fieldValue,
                ),
              );
            }
          }
        }
      }
    }
  }

//
//
//

  Future<void> _processMethodAnnotations(
    String fullFilePath,
    ClassElement classElement,
    RegExp? methodNameFilter,
    TOnAnnotatedMethodCallback? onAnnotatedMethod,
    TOnMethodAnnotationFieldCallback? onMethodAnnotationField,
    Set<String>? inclMethodAnnotations,
  ) async {
    for (final method in classElement.methods) {
      if (methodNameFilter == null || methodNameFilter.hasMatch(method.displayName)) {
        for (final methodMetadata in method.metadata) {
          final methodAnnotationName = methodMetadata.element?.displayName;
          if (methodAnnotationName != null &&
              inclMethodAnnotations?.contains(methodAnnotationName) != false) {
            final parent = OnAnnotatedMethodParams(
              fullFilePath: fullFilePath,
              methodAnnotationName: methodAnnotationName,
              methodName: method.displayName,
              methodType: method.type.getDisplayString(),
            );
            final stick = await onAnnotatedMethod?.call(parent);
            if (onMethodAnnotationField != null) {
              final element = methodMetadata.element;
              final fieldNames = element?.children.map((e) => e.displayName);
              if (fieldNames != null) {
                for (final fieldName in fieldNames) {
                  final fieldValue = methodMetadata.computeConstantValue()?.getField(fieldName);
                  if (fieldValue != null) {
                    await onMethodAnnotationField(
                      OnMethodAnnotationFieldParams(
                        parent: parent,
                        stick: stick,
                        fullFilePath: fullFilePath,
                        fieldName: fieldName,
                        fieldValue: fieldValue,
                      ),
                    );
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //
  //
  //

  Future<void> _processClassAnnotations(
    String fullFilePath,
    ClassElement classElement,
    TOnAnnotatedClassCallback? onAnnotatedClass,
    TOnClassAnnotationFieldCallback? onClassAnnotationField,
    Set<String>? inclClassAnnotations,
  ) async {
    for (final metadata in classElement.metadata) {
      final element = metadata.element;
      final classAnnotationName = element?.displayName;
      if (classAnnotationName != null &&
          inclClassAnnotations?.contains(classAnnotationName) != false) {
        final parent = OnAnnotatedClassParams(
          fullFilePath: fullFilePath,
          classAnnotationName: classAnnotationName,
          className: classElement.displayName,
        );
        final stick = await onAnnotatedClass?.call(parent);
        if (onClassAnnotationField != null) {
          final fieldNames = element?.children.map((e) => e.displayName);
          if (fieldNames != null) {
            for (final fieldName in fieldNames) {
              final fieldValue = metadata.computeConstantValue()?.getField(fieldName);
              if (fieldValue != null) {
                await onClassAnnotationField(
                  OnClassAnnotationFieldParams(
                    parent: parent,
                    stick: stick,
                    fullFilePath: fullFilePath,
                    fieldName: fieldName,
                    fieldValue: fieldValue,
                  ),
                );
              }
            }
          }
        }
      }
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Params for [TOnAnnotatedClassCallback].
final class OnAnnotatedClassParams {
  final String fullFilePath;
  final String classAnnotationName;
  final String className;

  const OnAnnotatedClassParams({
    required this.fullFilePath,
    required this.classAnnotationName,
    required this.className,
  });
}

typedef TOnAnnotatedClassCallback = Future<dynamic> Function(
  OnAnnotatedClassParams parent,
);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Params for [TOnClassAnnotationFieldCallback].
final class OnClassAnnotationFieldParams {
  final OnAnnotatedClassParams parent;
  final dynamic stick;
  final String fullFilePath;
  final String fieldName;
  final DartObject fieldValue;

  const OnClassAnnotationFieldParams({
    required this.parent,
    required this.stick,
    required this.fullFilePath,
    required this.fieldName,
    required this.fieldValue,
  });
}

typedef TOnClassAnnotationFieldCallback = Future<dynamic> Function(
  OnClassAnnotationFieldParams parent,
);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Params for [TOnAnnotatedMethodCallback].
final class OnAnnotatedMethodParams {
  final String fullFilePath;
  final String methodAnnotationName;
  final String methodName;
  final String methodType;

  const OnAnnotatedMethodParams({
    required this.fullFilePath,
    required this.methodAnnotationName,
    required this.methodName,
    required this.methodType,
  });
}

typedef TOnAnnotatedMethodCallback = Future<dynamic> Function(
  OnAnnotatedMethodParams parent,
);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Params for [TOnMethodAnnotationFieldCallback].
final class OnMethodAnnotationFieldParams {
  final OnAnnotatedMethodParams parent;
  final dynamic stick;
  final String fullFilePath;
  final String fieldName;
  final DartObject fieldValue;

  const OnMethodAnnotationFieldParams({
    required this.parent,
    required this.stick,
    required this.fullFilePath,
    required this.fieldName,
    required this.fieldValue,
  });
}

typedef TOnMethodAnnotationFieldCallback = Future<dynamic> Function(
  OnMethodAnnotationFieldParams parent,
);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Params for [TOnAnnotatedMemberCallback].
final class OnAnnotatedMemberParams {
  final String fullFilePath;
  final String memberAnnotationName;
  final Map<String, DartObject> memberAnnotationFields;
  final String memberName;
  final DartType memberType;

  const OnAnnotatedMemberParams({
    required this.fullFilePath,
    required this.memberAnnotationName,
    required this.memberAnnotationFields,
    required this.memberName,
    required this.memberType,
  });
}

typedef TOnAnnotatedMemberCallback = Future<dynamic> Function(
  OnAnnotatedMemberParams parent,
);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Params for [TOnMemberAnnotationFieldsCallback].
final class OnMemberAnnotationFieldParams {
  final OnAnnotatedMemberParams parent;
  final dynamic stick;
  final String fullFilePath;
  final String fieldName;
  final DartObject fieldValue;

  const OnMemberAnnotationFieldParams({
    required this.parent,
    required this.stick,
    required this.fullFilePath,
    required this.fieldName,
    required this.fieldValue,
  });
}

typedef TOnMemberAnnotationFieldsCallback = Future<dynamic> Function(
  OnMemberAnnotationFieldParams parent,
);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TOnPreAnalysis = void Function(String fullFilePath, String className);

typedef TOnPostAnalysis = void Function(OnAnnotatedClassParams params);
