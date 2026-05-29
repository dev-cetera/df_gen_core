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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Spinner {
  String label;

  Spinner({this.label = '***'});
  Spinner.start({this.label = '***'}) {
    start();
  }

  Timer? _timer;
  int _index = 0;
  final List<String> _spinner = ['|', '/', '-', '\\'];

  /// Runs the given function while showing a spinner animation. The spinner
  /// is always stopped before this returns — even when [fn] throws — so the
  /// terminal isn't left with a dangling timer that keeps printing.
  Future<void> run(Future<void> Function() fn) async {
    start();
    try {
      await fn();
    } finally {
      stop();
    }
  }

  /// Starts the spinner animation. No-op when [stdout] is not attached to a
  /// terminal — animating into a pipe or log file would just write control
  /// characters that pollute captured output.
  void start() {
    stop();
    if (!stdout.hasTerminal) return;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      stdout.write('\r${_spinner[_index]}');
      _index = (_index + 1) % _spinner.length;
    });
  }

  void stop() {
    if (_timer != null) {
      if (stdout.hasTerminal) {
        stdout.write('\r');
      }
      _timer!.cancel();
      _timer = null;
    }
  }

  void printAndResume(void Function(String message) print, String message) {
    stop();
    print('[$label] $message');
    start();
  }
}
