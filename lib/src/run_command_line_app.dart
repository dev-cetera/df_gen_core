//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. SSee MIT LICENSE
// file in the root directory.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:io';

import 'package:args/args.dart';
import 'package:df_log/df_log.dart';

import 'print_arg_parser_usage.dart';
import 'valid_args_checker.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A helper for creating and running a basic command-line application.
Future<void> runCommandLineApp<T extends ValidArgsChecker>({
  required String title,
  required String description,
  required List<String> args,
  required ArgParser parser,
  required T Function(
    ArgParser parser,
    ArgResults results,
  ) onResults,
  required Future<void> Function(
    ArgParser parser,
    ArgResults results,
    T checker,
  ) action,
}) async {
  try {
    late ArgResults results;
    try {
      results = parser.parse(args);
    } catch (e) {
      Here().debugLogError('Failed to parse arguments $e');
      return;
    }
    if (results['help']) {
      printArgParserUsage(
        parser,
        title: title,
        description: description,
      );
      return;
    }
    final checker = onResults(parser, results);
    if (!checker.isValid) {
      Here().debugLogError('You must provide all required options.');
      printArgParserUsage(
        parser,
        title: title,
        description: description,
      );
      exit(1);
    }
    await action(parser, results, checker);
  } catch (e) {
    Here().debugLogError(e);
    rethrow;
  }
}
