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

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

import '../df_gen_core.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mechanism to explore files and folders from specified [combinations].
///
/// The exploration is streaming: only one [FileSystemEntity] at a time is
/// held in memory regardless of tree size. Each directory finding's [files]
/// and [dirs] streams are lazy and walk the directory on subscription, so
/// they can be iterated independently of the main [explore] stream.
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
    for (final get in combinations) {
      for (final dirPath in get()) {
        yield* _walk(dirPath, null);
      }
    }
  }

  /// Yields every finding under [dirPath] in pre-order: the parent directory
  /// is emitted before any of its descendants. No intermediate buffering.
  static Stream<PathExplorerFinding> _walk(
    String dirPath,
    DirPathExplorerFinding Function()? parentDir,
  ) async* {
    await for (final path in _normalizedDirContent(dirPath)) {
      final isDir = await FileSystemEntity.isDirectory(path);
      if (isDir) {
        DirPathExplorerFinding? self;
        self = DirPathExplorerFinding._(
          path: path,
          files: _lazyImmediateFiles(path),
          dirs: _lazyImmediateDirs(path),
          parentDir: parentDir,
        );
        yield self;
        yield* _walk(path, () => self!);
      } else {
        yield FilePathExplorerFinding._(path: path);
      }
    }
  }

  Stream<FileData> readFiles(bool Function(FilePathExplorerFinding) filter) {
    return exploreFiles().where(filter).asyncMap(
          (a) async => File(a.path).readAsBytes().then((b) => FileData(a, b)),
        );
  }

  /// Calls [explore] and reads the content of each file found up to [limit]
  /// files if specified. Returns a stream of [FileReadFinding] containing file
  /// paths and their content. Read errors are logged and skipped — they do not
  /// abort the traversal.
  Stream<FileReadFinding> readAll({int? limit}) async* {
    var count = 0;
    await for (final finding in explore()) {
      if (finding is FilePathExplorerFinding) {
        if (limit != null && count >= limit) {
          break;
        }
        try {
          final contents = await File(finding.path).readAsString();
          if (contents.isNotEmpty) {
            yield FileReadFinding._(path: finding.path, content: contents);
            count++;
          }
        } catch (e) {
          Log.printRed(
              'PathExplorer.readAll: failed to read ${finding.path} ($e)',);
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

  String get baseName => p.basename(path);

  //
  //
  //

  String get rootName => baseName.replaceFirst(RegExp(r'\..*'), '');

  //
  //
  //

  @override
  List<Object?> get props => [path, content];
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
      yield* dir.getSubFiles();
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

/// Lists all immediate contents of [dirPath]. Yields normalized paths.
///
/// If the directory cannot be opened, the error is logged and the stream
/// closes empty — the traversal continues with the next directory rather
/// than aborting.
Stream<String> _normalizedDirContent(String dirPath) async* {
  final dir = Directory(dirPath);
  try {
    yield* dir.list(recursive: false).handleError(
      (Object e) {
        Log.printRed('PathExplorer: error listing entry in $dirPath ($e)');
      },
      test: (_) => true,
    ).map((e) => p.normalize(e.path));
  } catch (e) {
    Log.printRed('PathExplorer: cannot list $dirPath ($e)');
  }
}

/// Lazy stream of immediate files in [dirPath], rebuilt on each subscription.
Stream<FilePathExplorerFinding> _lazyImmediateFiles(String dirPath) async* {
  await for (final path in _normalizedDirContent(dirPath)) {
    if (await FileSystemEntity.isFile(path)) {
      yield FilePathExplorerFinding._(path: path);
    }
  }
}

/// Lazy stream of immediate subdirectories in [dirPath], rebuilt on each
/// subscription. The yielded findings carry lazy children streams of their
/// own so the consumer can keep walking without re-listing the parent.
Stream<DirPathExplorerFinding> _lazyImmediateDirs(String dirPath) async* {
  await for (final path in _normalizedDirContent(dirPath)) {
    if (await FileSystemEntity.isDirectory(path)) {
      yield DirPathExplorerFinding._(
        path: path,
        files: _lazyImmediateFiles(path),
        dirs: _lazyImmediateDirs(path),
        parentDir: null,
      );
    }
  }
}
