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

import 'dart:async' show FutureOr;
import 'dart:convert' show utf8;
import 'dart:io' show Directory, File, FileMode, Platform;
import 'dart:isolate' show Isolate;

import 'package:df_type/df_type.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '/df_gen_core.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class IoUtility {
  static const i = IoUtility._();

  const IoUtility._();

  /// Reads the contents of the file located at [filePath] as a String.
  Future<String?> readLocalFileOrNull(String filePath) async {
    try {
      final localSystemFilePath = toLocalSystemPathFormat(filePath);
      final file = File(localSystemFilePath);
      final data = await file.readAsString();
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Reads the contents of the file located at [filePath] as a list of lines.
  Future<List<String>?> readLocalFileAsLinesOrNull(String filePath) async {
    try {
      final localSystemFilePath = toLocalSystemPathFormat(filePath);
      final file = File(localSystemFilePath);
      final lines = await file.readAsLines();
      return lines;
    } catch (_) {
      return null;
    }
  }

  /// Reads the contents of the file located at [url] as a String.
  Future<String?> readFileFromUrlOrNull(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Reads the contents of a file located on GitHub as a String.
  Future<String?> readFileFromGitHubOrNull({
    required String username,
    required String repo,
    String branch = 'main',
    required String filePath,
  }) {
    final url = 'https://raw.githubusercontent.com/$username/$repo/$branch/$filePath';
    return readFileFromUrlOrNull(url);
  }

  /// Reads the contents of a file located at [pathOrUrl].
  Future<Result<String, Null>> readFileFromPathOrUrl(String pathOrUrl) async {
    return Result.tryCatchAsync(
      () async => (await readLocalFileOrNull(pathOrUrl) ?? await readFileFromUrlOrNull(pathOrUrl))!,
      (e) => null,
    );
  }

  /// Writes the given [content] to the file located at [filePath]. Set [append]
  /// to `true` to append the [content] to the file instead of overwriting it.
  Future<void> writeLocalFile(
    String filePath,
    String content, {
    bool append = false,
  }) async {
    final localSystemFilePath = toLocalSystemPathFormat(filePath);
    final file = File(localSystemFilePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      content,
      mode: append ? FileMode.append : FileMode.write,
    );
  }

  /// Clears the contents of the file located at [filePath].
  Future<void> clearLocalFile(String filePath) async {
    final localSystemFilePath = toLocalSystemPathFormat(filePath);
    final file = File(localSystemFilePath);
    await file.writeAsString('');
  }

  /// Deletes the file located at [filePath].
  Future<void> deleteLocalFile(String filePath) async {
    final localSystemFilePath = toLocalSystemPathFormat(filePath);
    final file = File(localSystemFilePath);
    await file.delete();
  }

  /// Returns `true` if the file located at [filePath] exists.
  Future<bool> localFileExists(String filePath) {
    final localSystemFilePath = toLocalSystemPathFormat(filePath);
    final file = File(localSystemFilePath);
    return file.exists();
  }

  /// Finds a file with the given [fileName] in [directoryPath] or subdirectories.
  Future<File?> findLocalFileByNameOrNull(
    String fileName,
    String directoryPath,
  ) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return null;
    final entities = directory.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('/$fileName')) {
        return entity;
      }
    }
    return null;
  }

  /// Lists the file paths of the files in the directory located at [dirPath].
  /// Set [recursive] to `true` to list the file paths of the files in
  /// the sub-directories as well.
  Future<List<String>?> listLocalFilePaths(
    String dirPath, {
    bool recursive = true,
  }) async {
    final localSystemDirPath = toLocalSystemPathFormat(dirPath);
    final dir = Directory(localSystemDirPath);
    final filePaths = <String>[];
    if (await dir.exists()) {
      final entities = dir.listSync(recursive: recursive);
      for (final entity in entities) {
        if (entity is File) {
          filePaths.add(entity.path);
        }
      }
    } else {
      return null;
    }
    return filePaths;
  }

  /// Gets the current OS's Desktop path.
  String? getDesktopPathOrNull() {
    if (Platform.isMacOS) {
      return p.join('Users', Platform.environment['USER']!, 'Desktop');
    } else if (Platform.isWindows) {
      return p.join(Platform.environment['USERPROFILE']!, 'Desktop');
    } else if (Platform.isLinux) {
      return p.join('home', Platform.environment['USER']!, 'Desktop');
    } else {
      return null;
    }
  }

  /// Returns the directory path of the current script.
  String get currentScriptDir => Directory.fromUri(Platform.script).parent.path;

  /// Returns the path of the `lib` directory of [package] or `null` if the
  /// package is not found.
  Future<String?> getPackageLibPath(String package) async {
    final packageUri = Uri.parse('package:$package/');
    final pathUri = await Isolate.resolvePackageUri(packageUri);
    if (pathUri == null) return null;
    var path = Uri.decodeFull(pathUri.path);

    // On Windows, adjust the path format.
    if (Platform.isWindows) {
      // Regular expression to match patterns like /CC:
      final driveLetterPattern = RegExp(r'^[/\\][A-Za-z]+:');
      if (driveLetterPattern.hasMatch(path)) {
        path = path.substring(1);
      }
      path = path.replaceAll('/', '\\');
    }
    return path;
  }

  /// Finds all source file paths in [rootDirPath] that for the given [lang].
  ///
  /// If [pathPatterns] is specified, only file paths that match all
  /// [pathPatterns] are added to the results.
  ///
  /// The [onFileFound] callback is invoked for each file, allowing for custom
  /// filtering, i.e. if the it returns `true`, the file is added, if it returns
  /// `false`, the file is not added.
  Future<List<String>> findSourceFilePaths(
    String rootDirPath, {
    required Lang lang,
    Set<String> pathPatterns = const {},
    FutureOr<bool> Function(String filePath)? onFileFound,
  }) async {
    return findFilePaths(
      rootDirPath,
      pathPatterns: pathPatterns,
      recursive: true,
      onFilePathFound: (result) async {
        final a = await onFileFound?.call(result) ?? true;
        final b = lang.isValidSrcFilePath(result);
        return a && b;
      },
    );
  }

  /// Finds all generated file paths in [rootDirPath] that for the given [lang].
  ///
  /// If [pathPatterns] is specified, only file paths that match all
  /// [pathPatterns] are added to the results.
  ///
  /// The [onFileFound] callback is invoked for each file, allowing for custom
  /// filtering, i.e. if the it returns `true`, the file is added, if it returns
  /// `false`, the file is not added.
  Future<List<String>> findGeneratedFilePaths(
    String rootDirPath, {
    required Lang lang,
    Set<String> pathPatterns = const {},
    FutureOr<bool> Function(String filePath)? onFileFound,
  }) async {
    return findFilePaths(
      rootDirPath,
      pathPatterns: pathPatterns,
      recursive: true,
      onFilePathFound: (result) async {
        final a = await onFileFound?.call(result) ?? true;
        final b = lang.isValidGenFilePath(result);
        return a && b;
      },
    );
  }

  /// Finds all files in [rootDirPath], including sub-directories if [recursive]
  /// is `true`.
  ///
  /// The [onFilePathFound] callback is invoked for each file, allowing for custom
  /// filtering, i.e. if the it returns `true`, the file is added, if it returns
  /// `false`, the file is not added.
  Future<List<String>> findFilePaths(
    String rootDirPath, {
    Set<String> pathPatterns = const {},
    bool recursive = true,
    FutureOr<bool> Function(String filePath)? onFilePathFound,
  }) async {
    final results = <String>[];
    final filePaths = await listLocalFilePaths(
      rootDirPath,
      recursive: recursive,
    );
    if (filePaths != null) {
      filePaths.sort();
      for (final filePath in filePaths) {
        final a = matchesAnyPathPattern(filePath, pathPatterns);
        if (!a) continue;

        final b = (await onFilePathFound?.call(filePath)) ?? true;
        if (!b) continue;
        results.add(filePath);
      }
    }
    return results;
  }
}
