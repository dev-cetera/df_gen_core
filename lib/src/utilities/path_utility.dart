//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// 🇽🇾🇿 & Dev
//
// Copyright Ⓒ Robert Mollentze
//
// Licensing details can be found in the LICENSE file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_collection/df_collection.dart';
import 'package:path/path.dart' as p;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class PathUtility {
  static const i = PathUtility._();

  const PathUtility._();

  /// Gets the part of [path] after the last separator and works for Windows and
  /// Unix paths, unlike [p.basename].
  String localBaseName(String path) {
    final localSystemFilePath = localize(path);
    return p.basename(localSystemFilePath);
  }

  /// Gets the part of [path] after the last separator, and without any trailing
  /// file extension and works for Windows and Unix paths, unlike
  /// [p.basenameWithoutExtension].
  String localBaseNameWithoutExtension(String path) {
    final localSystemFilePath = localize(path);
    return p.basenameWithoutExtension(localSystemFilePath);
  }

  /// Gets the part of [path] before the last separator and works for Windows and
  /// Unix paths, unlike [p.dirname].
  String localDirName(String path) {
    final localSystemFilePath = localize(path);
    return p.dirname(localSystemFilePath);
  }

  /// Replaces all forward slashes in [path] with the local path separator.
  String localize(String path) {
    return path.split(RegExp(r'[\\/]')).join(p.separator);
  }

  /// Gets all the components of [path].
  Iterable<String> components(String path) {
    return path.split(RegExp(r'[\\/]'));
  }

  /// Gets the last folder name from a given path, even if the path points to a
  /// file.

  String folderName(String path) {
    // Normalize the path to use the local separator
    final normalizedPath = localize(path);
    final folderPath = p.dirname(normalizedPath);
    return p.basename(folderPath);
  }
}

/// Takes the last 3 segments of the [path].
String previewPath(String path) {
  return '**${p.joinAll(p.split(path).takeLast(3))}';
}

/// Checks if the provided [path] contains any of the specified [components].
/// This operation is case-insensitive.
bool pathContainsComponent(String path, Set<String> components) {
  final localSystemFilePath = PathUtility.i.localize(path);
  final a = p.split(localSystemFilePath).map((e) => e.toLowerCase());
  for (final component in components) {
    if (a.contains(component.toLowerCase())) {
      return true;
    }
  }
  return false;
}

/// Checks if the provided [path] matches any of the specified [pathPatterns].
bool matchesAnyPathPattern(String path, Set<String> pathPatterns) {
  if (pathPatterns.isNotEmpty) {
    final localSystemFilePath = PathUtility.i.localize(path);
    for (final pattern in pathPatterns) {
      if (RegExp(pattern).hasMatch(localSystemFilePath)) return true;
    }
    return false;
  }
  return true;
}

/// Checks if the provided [filePath] matches any of the specified [extensions].
///
/// Notes:
///
/// - If the [extensions] set is empty, the function will return true.
/// - Specify [caseSensitive] as false to ignore case.
bool matchesAnyExtension(
  String filePath,
  Set<String> extensions, {
  bool caseSensitive = true,
}) {
  if (extensions.isEmpty) return true;
  final extension = p.extension(filePath);
  return extensions.any((e) {
    final a = caseSensitive ? extension : extension.toLowerCase();
    final b = caseSensitive ? e : e.toLowerCase();
    return a == b;
  });
}

/// Replaces all backslashes in [path] with forward slashes.
String toUnixSystemPathFormat(String path) {
  return path.split(RegExp(r'[\\/]')).join('/');
}

/// Replaces all forward slashes in [path] with backslashes.
String toWindowsSystemPathFormat(String path) {
  return path.split(RegExp(r'[\\/]')).join('\\');
}

/// Checks if the provided [filePath] is a private file (starts with an
/// underscore).
bool isPrivateFileName(String filePath) {
  final fileName = PathUtility.i.localBaseName(filePath);
  return fileName.startsWith('_');
}

/// Checks if the file name extracted from [filePath] matches the specified
/// beginning type [begType] and ending type [endType].
///
/// Returns a tuple with the match status and the file name.
({bool status, String fileName}) isMatchingFileName(
  String filePath,
  String begType,
  String endType,
) {
  final fileName = PathUtility.i.localBaseName(filePath);
  final a = begType.isEmpty
      ? true
      : fileName.startsWith('${begType.toLowerCase()}_');
  final b = endType.isEmpty
      ? true
      : fileName.endsWith('.$endType'.toLowerCase());
  final c = a && b;
  return (status: c, fileName: fileName);
}

/// Combines multiple [pathSets] into a single set, returning all possible
/// combinations.
///
/// Note: This function is recursive and works by joining the first two sets and
/// then combining the resulting set with the next set, until all sets are
/// processed.
///
/// Example:
/// ```dart
/// final pathSets = [
///   {'path1', 'path2'},
///   {'segmentA', 'segmentB'},
///   {'end1', 'end2'},
/// ];
/// final combinedPaths = combineSets(pathSets);
/// print(combinedPaths);
/// ```
///
/// Output:
/// ```
/// {path1/segmentA/end1, path1/segmentA/end2, path1/segmentB/end1, path1/segmentB/end2, path2/segmentA/end1, path2/segmentA/end2, path2/segmentB/end1, path2/segmentB/end2}
/// ```
Set<String> combinePathSets(List<Set<String>> pathSets) {
  late Set<String> output;
  final input = List.of(pathSets).where((e) => e.isNotEmpty).toList();
  if (input.isEmpty) {
    output = {};
  } else if (input.length == 1) {
    output = input[0];
  } else {
    final joined = <String>{};
    for (final a in input[0]) {
      for (final b in input[1]) {
        if (b.isEmpty) {
          joined.add(a);
        } else if (a.isEmpty) {
          joined.add(b);
        } else {
          joined.add(p.join(a, b));
        }
      }
    }
    output = combinePathSets([joined, ...input.skip(2)]);
  }
  output = output.map((e) => p.normalize(PathUtility.i.localize(e))).toSet();
  return output;
}
