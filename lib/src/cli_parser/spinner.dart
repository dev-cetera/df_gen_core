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

  /// Runs the given function while showing a spinner animation.
  Future<void> run(Future<void> Function() fn) async {
    start();
    await fn();
    stop();
  }

  /// Starts the spinner animation.
  void start() {
    stop();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      stdout.write('\r${_spinner[_index]}');
      _index = (_index + 1) % _spinner.length;
    });
  }

  void stop() {
    if (_timer != null) {
      stdout.write('\r');
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
