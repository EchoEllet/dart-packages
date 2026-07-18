import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _processTimeout = Duration(seconds: 3);

Future<ProcessResult> _runProcess(
  String executable,
  List<String> arguments, {
  String? stdin,
}) async {
  final process = await Process.start(executable, arguments);

  if (stdin != null) {
    process.stdin.write(stdin);
  }
  await process.stdin.close();

  try {
    final stdout = utf8.decodeStream(process.stdout);
    final stderr = utf8.decodeStream(process.stderr);
    final exitCode = process.exitCode;

    return await () async {
      return ProcessResult(
        process.pid,
        await exitCode,
        await stdout,
        await stderr,
      );
    }().timeout(_processTimeout);
  } on TimeoutException {
    process.kill();
    rethrow;
  }
}

/// Runs the `secret-tool` command-line utility.
Future<ProcessResult> _runSecretTool(List<String> arguments, {String? stdin}) {
  return _runProcess('secret-tool', arguments, stdin: stdin);
}

/// A secret stored by GNOME libsecret.
final class LibsecretItem {
  const LibsecretItem({
    required this.label,
    required this.secret,
    required this.created,
    required this.modified,
    required this.attributes,
  });

  final String label;
  final String secret;
  final DateTime created;
  final DateTime modified;
  final Map<String, String> attributes;
}

/// Interface used by interoperability tests.
///
/// Implementations may use:
/// - `secret-tool` CLI (provided by GNOME libsecret)
/// - FFI
/// - any other GNOME libsecret API
abstract interface class LibsecretInterop {
  Future<void> store({
    required String label,
    required String secret,
    required Map<String, String> attributes,
    String? collection,
  });

  Future<String?> lookup({required Map<String, String> attributes});

  Future<List<LibsecretItem>> search({required Map<String, String> attributes});

  Future<bool> clear({required Map<String, String> attributes});
}

/// An implementation of [LibsecretInterop] backed by the `secret-tool`
/// command-line utility provided by GNOME libsecret.
final class LibsecretInteropSecretTool implements LibsecretInterop {
  const LibsecretInteropSecretTool();

  @override
  Future<void> store({
    required String label,
    required String secret,
    required Map<String, String> attributes,
    String? collection,
  }) async {
    final arguments = [
      'store',
      '--label=$label',
      if (collection != null) '--collection=$collection',
      ..._attributeArguments(attributes),
    ];
    final result = await _runSecretTool(arguments, stdin: secret);

    _throwIfFailed(result, arguments);
  }

  @override
  Future<String?> lookup({required Map<String, String> attributes}) async {
    final arguments = ['lookup', ..._attributeArguments(attributes)];
    final result = await _runSecretTool(arguments);

    if (result.exitCode == 1) {
      return null;
    }

    _throwIfFailed(result, arguments);

    final output = (result.stdout as String).trimRight();

    if (output.isEmpty) {
      return null;
    }

    return output;
  }

  @override
  Future<List<LibsecretItem>> search({
    required Map<String, String> attributes,
  }) async {
    final arguments = ['search', '--all', ..._attributeArguments(attributes)];
    final result = await _runSecretTool(arguments);

    _throwIfFailed(result, arguments);

    final output = (result.stdout as String).trim();

    if (output.isEmpty) {
      return const [];
    }

    return _parseSearchOutput(output);
  }

  @override
  Future<bool> clear({required Map<String, String> attributes}) async {
    final arguments = ['clear', ..._attributeArguments(attributes)];
    final result = await _runSecretTool(arguments);

    if (result.exitCode == 1) {
      return false;
    }

    _throwIfFailed(result, arguments);

    return true;
  }

  static Iterable<String> _attributeArguments(
    Map<String, String> attributes,
  ) sync* {
    for (final entry in attributes.entries) {
      yield entry.key;
      yield entry.value;
    }
  }

  static void _throwIfFailed(ProcessResult result, List<String> arguments) {
    if (result.exitCode == 0) {
      return;
    }

    throw SecretToolException(
      arguments: arguments,
      exitCode: result.exitCode,
      stderr: (result.stderr as String).trim(),
    );
  }

  static List<LibsecretItem> _parseSearchOutput(String output) {
    final items = <LibsecretItem>[];

    final normalized = output.replaceAll('\r\n', '\n');

    final blocks = normalized
        .split(RegExp(r'(?=\[\/\d+\])'))
        .where((block) => block.trim().isNotEmpty);

    for (final block in blocks) {
      String? label;
      String? secret;
      DateTime? created;
      DateTime? modified;
      final attributes = <String, String>{};

      for (final rawLine in block.split('\n')) {
        final line = rawLine.trim();

        if (line.isEmpty) {
          continue;
        }

        final separator = line.indexOf('=');

        if (separator == -1) {
          continue;
        }

        final key = line.substring(0, separator).trim();
        final value = line.substring(separator + 1).trim();

        switch (key) {
          case 'label':
            label = value;

          case 'secret':
            secret = value;

          case 'created':
            created = DateTime.parse(value.replaceFirst(' ', 'T'));

          case 'modified':
            modified = DateTime.parse(value.replaceFirst(' ', 'T'));

          // `secret-tool search` outputs the `xdg:schema` attribute as `schema`
          // instead of the normal `attribute.xdg:schema` format. Normalize it back
          // to the original attribute name.
          case 'schema':
            attributes['xdg:schema'] = value;

          default:
            if (key.startsWith('attribute.')) {
              attributes[key.substring('attribute.'.length)] = value;
            }
        }
      }

      if (label == null ||
          secret == null ||
          created == null ||
          modified == null) {
        throw const FormatException(
          'Unexpected output from secret-tool search.',
        );
      }

      items.add(
        LibsecretItem(
          label: label,
          secret: secret,
          created: created,
          modified: modified,
          attributes: attributes,
        ),
      );
    }

    return items;
  }
}

/// Thrown when a `secret-tool` command cannot be completed successfully.
final class SecretToolException implements Exception {
  const SecretToolException({
    required this.arguments,
    required this.exitCode,
    required this.stderr,
  });

  final List<String> arguments;
  final int exitCode;
  final String stderr;

  @override
  String toString() {
    return 'SecretToolException: '
        'secret-tool exited with code $exitCode.\n'
        '  Command: secret-tool ${arguments.join(' ')}\n'
        '  stderr: ${stderr.isEmpty ? '<empty>' : stderr}';
  }
}
