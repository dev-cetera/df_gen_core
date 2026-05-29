import 'dart:io';

import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

void main() {
  group('ProcessOutcome construction', () {
    test('preconditionFailed marks not ok with reason in stderr', () {
      final o = ProcessOutcome.preconditionFailed('file missing');
      expect(o.ok, isFalse);
      expect(o.exitCode, -1);
      expect(o.stderr, 'file missing');
      expect(o.launchError, isNull);
    });

    test('launchFailed marks not ok and records the reason in launchError', () {
      final o = ProcessOutcome.launchFailed('not installed');
      expect(o.ok, isFalse);
      expect(o.exitCode, -1);
      expect(o.launchError, 'not installed');
    });

    test('fromResult preserves exit code and ok flag', () {
      final r = ProcessResult(0, 0, 'out', 'err');
      final o = ProcessOutcome.fromResult(r);
      expect(o.ok, isTrue);
      expect(o.exitCode, 0);
      expect(o.stdout, 'out');
      expect(o.stderr, 'err');
    });

    test('fromResult with non-zero exit code is not ok', () {
      final r = ProcessResult(0, 2, '', 'boom');
      final o = ProcessOutcome.fromResult(r);
      expect(o.ok, isFalse);
      expect(o.exitCode, 2);
    });

    test('summary picks last non-empty stderr line for non-ok outcomes', () {
      final o = ProcessOutcome.fromResult(
        ProcessResult(0, 1, '', 'warn\nfinal error line'),
      );
      expect(o.summary(), contains('final error line'));
    });

    test('summary falls back to "launch failed" when launchError is set', () {
      final o = ProcessOutcome.launchFailed('no such file or directory');
      expect(o.summary(), contains('launch failed'));
    });
  });

  group('Language-support tools — precondition checks', () {
    test('fmtDartFile returns preconditionFailed for missing file', () async {
      final o = await fmtDartFile('/tmp/df_gen_core_definitely_missing.dart');
      expect(o.ok, isFalse);
      expect(o.stderr, contains('file not found'));
    });

    test('fixDartFile returns preconditionFailed for missing file', () async {
      final o = await fixDartFile('/tmp/df_gen_core_definitely_missing.dart');
      expect(o.ok, isFalse);
    });

    test('fmtRustFile returns preconditionFailed for missing file', () async {
      final o = await fmtRustFile('/tmp/df_gen_core_definitely_missing.rs');
      expect(o.ok, isFalse);
    });

    test('fixRustFile returns preconditionFailed for missing file', () async {
      final o = await fixRustFile('/tmp/df_gen_core_definitely_missing.rs');
      expect(o.ok, isFalse);
    });

    test('fmtTsJsFile returns preconditionFailed for missing file', () async {
      final o = await fmtTsJsFile('/tmp/df_gen_core_definitely_missing.ts');
      expect(o.ok, isFalse);
    });

    test('fixTsJsFile returns preconditionFailed for missing file', () async {
      final o = await fixTsJsFile('/tmp/df_gen_core_definitely_missing.ts');
      expect(o.ok, isFalse);
    });
  });
}
