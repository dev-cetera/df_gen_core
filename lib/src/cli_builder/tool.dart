import 'package:args/args.dart';

// TODO: Add a command line package called df_cli_builder

final class CliParser {
  final String title;
  final String description;
  final String example;
  final String additional;
  final List<Param> params;

  const CliParser({
    this.title = '',
    this.description = '',
    this.example = '',
    this.additional = '',
    required this.params,
  });

  void addParamsTo(ArgParser argParser) {
    for (final param in params) {
      param.add(argParser);
    }
  }

  (ArgResults argResults, ArgParser argParser) parse(List<String> args) {
    final argParser = ArgParser();
    addParamsTo(argParser);
    final argResults = argParser.parse(args);
    return (
      argResults,
      argParser,
    );
  }

  String getInfo(ArgParser argParser) {
    final buffer = StringBuffer();
    buffer.writeln();
    if (title.isNotEmpty) {
      buffer.writeln('╔${'═' * (title.length + 2)}╗');
      buffer.writeln('║ $title ║');
      buffer.writeln('╚${'═' * (title.length + 2)}╝');
      buffer.writeln();
    }
    if (description.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln();
    }
    if (example.isNotEmpty) {
      buffer.writeln('e.g. "$example"');
      buffer.writeln();
    }
    buffer.write(argParser.usage);
    buffer.writeln();
    if (additional.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(additional);
    }
    return buffer.toString();
  }
}

sealed class Param {
  final String name;
  final String? abbr;
  final String? help;
  final List<String> aliases;
  final bool hide;

  const Param({
    required this.name,
    this.abbr,
    this.help,
    this.hide = false,
    this.aliases = const [],
  });

  void add(ArgParser argParser);

  Flag get asFlag => this as Flag;
  MultiOption get asMultiOption => this as MultiOption;
  Option get asOption => this as Option;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Param && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

final class Flag extends Param {
  final bool? defaultsTo;
  final bool negatable;
  final void Function(bool)? callback;

  const Flag({
    required super.name,
    super.abbr,
    super.help,
    this.defaultsTo = false,
    this.negatable = true,
    this.callback,
    super.hide,
    super.aliases,
  });

  @override
  void add(ArgParser argParser) {
    argParser.addFlag(
      name,
      abbr: abbr,
      help: help,
      defaultsTo: defaultsTo,
      negatable: negatable,
      callback: callback,
      hide: hide,
      aliases: aliases,
    );
  }

  Flag copyWith({
    String? name,
    String? abbr,
    String? help,
    bool? defaultsTo,
    bool? negatable,
    void Function(bool)? callback,
    bool? hide,
    List<String>? aliases,
  }) {
    return Flag(
      name: name ?? this.name,
      abbr: abbr ?? this.abbr,
      help: help ?? this.help,
      defaultsTo: defaultsTo ?? this.defaultsTo,
      negatable: negatable ?? this.negatable,
      callback: callback ?? this.callback,
      hide: hide ?? this.hide,
      aliases: aliases ?? this.aliases,
    );
  }
}

final class Option extends Param {
  final String? valueHelp;
  final Iterable<String>? allowed;
  final Map<String, String>? allowedHelp;
  final String? defaultsTo;
  final void Function(String?)? callback;
  final bool mandatory;

  const Option({
    required super.name,
    super.abbr,
    super.help,
    this.valueHelp,
    this.allowed,
    this.allowedHelp,
    this.defaultsTo,
    this.callback,
    this.mandatory = false,
    super.hide,
    super.aliases,
  });

  @override
  void add(ArgParser argParser) {
    argParser.addOption(
      name,
      abbr: abbr,
      help: help,
      valueHelp: valueHelp,
      allowed: allowed,
      allowedHelp: allowedHelp,
      defaultsTo: defaultsTo,
      callback: callback,
      mandatory: mandatory,
      hide: hide,
      aliases: aliases,
    );
  }

  Option copyWith({
    String? name,
    String? abbr,
    String? help,
    String? valueHelp,
    Iterable<String>? allowed,
    Map<String, String>? allowedHelp,
    String? defaultsTo,
    void Function(String?)? callback,
    bool? mandatory,
    bool? hide,
    List<String>? aliases,
  }) {
    return Option(
      name: name ?? this.name,
      abbr: abbr ?? this.abbr,
      help: help ?? this.help,
      valueHelp: valueHelp ?? this.valueHelp,
      allowed: allowed ?? this.allowed,
      allowedHelp: allowedHelp ?? this.allowedHelp,
      defaultsTo: defaultsTo ?? this.defaultsTo,
      callback: callback ?? this.callback,
      mandatory: mandatory ?? this.mandatory,
      hide: hide ?? this.hide,
      aliases: aliases ?? this.aliases,
    );
  }
}

final class MultiOption extends Param {
  final String? valueHelp;
  final Iterable<String>? allowed;
  final Map<String, String>? allowedHelp;
  final Iterable<String>? defaultsTo;
  final void Function(List<String>)? callback;
  final bool splitCommas;

  const MultiOption({
    required super.name,
    super.abbr,
    super.help,
    this.valueHelp,
    this.allowed,
    this.allowedHelp,
    this.defaultsTo,
    this.callback,
    this.splitCommas = true,
    super.hide,
    super.aliases,
  });

  @override
  void add(ArgParser argParser) {
    argParser.addMultiOption(
      name,
      abbr: abbr,
      help: help,
      valueHelp: valueHelp,
      allowed: allowed,
      allowedHelp: allowedHelp,
      defaultsTo: defaultsTo,
      callback: callback,
      splitCommas: splitCommas,
      hide: hide,
      aliases: aliases,
    );
  }

  MultiOption copyWith({
    String? name,
    String? abbr,
    String? help,
    String? valueHelp,
    Iterable<String>? allowed,
    Map<String, String>? allowedHelp,
    Iterable<String>? defaultsTo,
    void Function(List<String>)? callback,
    bool? splitCommas,
    bool? hide,
    List<String>? aliases,
  }) {
    return MultiOption(
      name: name ?? this.name,
      abbr: abbr ?? this.abbr,
      help: help ?? this.help,
      valueHelp: valueHelp ?? this.valueHelp,
      allowed: allowed ?? this.allowed,
      allowedHelp: allowedHelp ?? this.allowedHelp,
      defaultsTo: defaultsTo ?? this.defaultsTo,
      callback: callback ?? this.callback,
      splitCommas: splitCommas ?? this.splitCommas,
      hide: hide ?? this.hide,
      aliases: aliases ?? this.aliases,
    );
  }
}

enum DefaultFlags {
  HELP(
    Flag(
      name: 'help',
      abbr: 'h',
      help: 'Help information.',
      negatable: false,
    ),
  );

  final Flag flag;
  const DefaultFlags(this.flag);

  String get name => flag.name;

  @override
  String toString() {
    return name;
  }
}

enum DefaultOptions {
  DART_SDK(
    Option(
      name: 'dart-sdk',
      help: 'Dart SDK path. Alternatively, set the "DART_SDK" path env variable.',
    ),
  ),
  INPUT_PATH(
    Option(
      name: 'input',
      abbr: 'i',
      help: 'Source input path.',
    ),
  ),
  OUTPUT_PATH(
    Option(
      name: 'output',
      abbr: 'o',
      help: 'Output path.',
    ),
  ),
  GENERATED_OUTPUT(
    Option(
      name: 'output',
      abbr: 'o',
      help: 'Generated output path.',
    ),
  ),
  TEMPLATE_PATH_OR_URL(
    Option(
      name: 'template',
      abbr: 't',
      help: 'Source template path or URL.',
    ),
  );

  final Option option;
  const DefaultOptions(this.option);

  String get name => option.name;

  @override
  String toString() {
    return name;
  }
}

enum DefaultMultiOptions {
  ROOTS(
    MultiOption(
      name: 'roots',
      abbr: 'r',
      help: 'Root directory input paths.',
      defaultsTo: ['.'],
    ),
  ),
  SUBS(
    MultiOption(
      name: 'subs',
      abbr: 's',
      help: 'Sub-directory input paths.',
      defaultsTo: ['.'],
    ),
  ),
  PATH_PATTERNS(
    MultiOption(
      name: 'patterns',
      abbr: 'p',
      help: 'Patterns to match paths to include.',
    ),
  ),
  TEMPLATES(
    MultiOption(
      name: 'templates',
      abbr: 't',
      help: 'Source template paths or URLs.',
    ),
  );

  final MultiOption multiOption;
  const DefaultMultiOptions(this.multiOption);

  String get name => multiOption.name;

  @override
  String toString() {
    return name;
  }
}
