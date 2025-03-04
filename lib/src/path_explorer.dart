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

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

import '../df_gen_core.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mechanism to explore files and folders from specified [combinations].
class PathExplorer {
  //
  //
  //

  final Set<GetPathCombinations> combinations;

  //
  //
  //

  factory PathExplorer(String inputPath) {
    return PathExplorer.combinations(
      combinations: {
        GetPathCombinations([
          {inputPath},
        ]),
      },
    );
  }

  const PathExplorer.combinations({required this.combinations});

  //
  //
  //

  Stream<FilePathExplorerFinding> exploreFiles() {
    return explore()
        .where((e) => e is FilePathExplorerFinding)
        .cast<FilePathExplorerFinding>();
  }

  Stream<DirPathExplorerFinding> exploreDirs() {
    return explore()
        .where((e) => e is DirPathExplorerFinding)
        .cast<DirPathExplorerFinding>();
  }

  Stream<PathExplorerFinding> explore() async* {
    Stream<PathExplorerFinding> recurse(
      String dirPath,
      DirPathExplorerFinding Function()? parentDir,
    ) async* {
      final paths = _normalizedDirContent(dirPath);
      await for (final path in paths) {
        if (await FileSystemEntity.isDirectory(path)) {
          DirPathExplorerFinding? temp;
          final s = recurse(path, () => temp!);
          temp = DirPathExplorerFinding._(
            path: path,
            files: s
                .where((e) => e is FilePathExplorerFinding)
                .cast<FilePathExplorerFinding>(),
            dirs: s
                .where((e) => e is DirPathExplorerFinding)
                .cast<DirPathExplorerFinding>(),
            parentDir: parentDir,
          );
          yield temp;
          yield* s;
        } else {
          yield FilePathExplorerFinding._(path: path);
        }
      }
    }

    for (final get in combinations) {
      for (final dirPath in get()) {
        final dirFindingStream = recurse(dirPath, null);

        // Yield the top-level findings and subdirectories/files
        yield* dirFindingStream;
      }
    }
  }

  Stream<FileData> readFiles(bool Function(FilePathExplorerFinding) filter) {
    return exploreFiles().where(filter).asyncMap(
          (a) async => File(a.path).readAsBytes().then((b) => FileData(a, b)),
        );
  }

  /// Calls [explore] and reads the content of each file found up to [limit] files if specified.
  /// Returns a stream of [FileReadFinding] containing file paths and their content.
  Stream<FileReadFinding> readAll({int? limit}) async* {
    final explorerStream = explore();
    var count = 0;

    await for (final finding in explorerStream) {
      if (finding is FilePathExplorerFinding) {
        if (limit != null && count >= limit) {
          break;
        }
        try {
          final path = finding.path;
          final file = File(path);
          final contents = await file.readAsString();
          if (contents.isNotEmpty) {
            yield FileReadFinding._(path: path, content: contents);
            count++;
          }
        } catch (_) {
          // Optionally handle errors here
        }
      }
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef TPathExplorerFindings = Future<
    ({
      Set<DirPathExplorerFinding> rootDirPathFindings,
      Set<DirPathExplorerFinding> dirPathFindings,
      Set<FilePathExplorerFinding> filePathFindings,
    })>;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class FileReadFinding extends Equatable {
  //
  //
  //

  final String path;
  final String content;

  //
  //
  //

  const FileReadFinding._({required this.path, required this.content});

  //
  //
  //

  String get baseName => p.basename(this.path);

  //
  //
  //

  String get rootName => this.baseName.replaceFirst(RegExp(r'\..*'), '');

  //
  //
  //

  @override
  List<Object?> get props => [this.path, this.content];
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class FileData {
  final FilePathExplorerFinding finding;
  final Uint8List content;
  const FileData(this.finding, this.content);

  String contentAsString() => String.fromCharCodes(content);
}

final class FilePathExplorerFinding extends PathExplorerFinding {
  //
  //
  //

  const FilePathExplorerFinding._({required super.path});
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class DirPathExplorerFinding extends PathExplorerFinding {
  //
  //
  //

  final Stream<FilePathExplorerFinding> files;
  final Stream<DirPathExplorerFinding> dirs;
  final DirPathExplorerFinding Function()? parentDir;

  //
  //
  //

  const DirPathExplorerFinding._({
    required super.path,
    required this.files,
    required this.dirs,
    required this.parentDir,
  });

  //
  //
  //

  Stream<DirPathExplorerFinding> getSubDirs() async* {
    await for (final dir in dirs) {
      yield dir;
      yield* dir.getSubDirs();
    }
  }

  Stream<FilePathExplorerFinding> getSubFiles() async* {
    await for (final file in files) {
      yield file;
    }
    await for (final dir in dirs) {
      yield* dir.getSubFiles().asBroadcastStream();
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

sealed class PathExplorerFinding {
  //
  //
  //

  final String path;

  //
  //
  //

  const PathExplorerFinding({required this.path});
}

//
//
//

/// Lists all contents of the given [dirPath].
Stream<String> _normalizedDirContent(String dirPath) async* {
  final dir = Directory(dirPath);
  yield* dir.list(recursive: false).map((e) => p.normalize(e.path));
}

// Stream<FilePathExplorerFinding> flattenDirsToFiles(Stream<PathExplorerFinding> dirStream) async* {
//   await for (final e in dirStream) {
//     if (e is DirPathExplorerFinding) {
//       yield* e.files;
//       yield* flattenDirsToFiles(e.dirs);
//     }
//     if (e is FilePathExplorerFinding) {
//       yield e;
//     }
//   }
// }
