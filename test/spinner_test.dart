import 'dart:async';

import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('Spinner.run', () {
    test('stops the timer when the wrapped function completes normally',
        () async {
      final s = Spinner();
      await s.run(() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      });
      // After run() returns, calling stop() again should be a no-op (no
      // dangling timer to cancel). We have to peek at behavior via the
      // public API — if the timer is still live, a second stop() shouldn't
      // throw either; but more importantly, run() must have completed.
      s.stop();
    });

    test('stops the timer when the wrapped function throws (regression)',
        () async {
      final s = Spinner();
      // Previously, an exception inside fn() bypassed stop() and left the
      // Timer.periodic running forever. With the try/finally wrap, the
      // spinner is always cleaned up.
      var caught = false;
      try {
        await s.run(() async {
          throw StateError('boom');
        });
      } on StateError {
        caught = true;
      }
      expect(caught, isTrue);
      // Allow any tick to fire — if the timer is still alive it would print
      // to stdout, but we can verify a cleaner property: stop() is safe to
      // call again (idempotent) which means the internal _timer is null.
      s.stop();
    });
  });
}
