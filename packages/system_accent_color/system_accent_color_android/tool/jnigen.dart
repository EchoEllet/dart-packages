import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) async {
  final packageRoot = Platform.script.resolve('../');
  final generator = JniGenerator(
    input: .new(
      androidSdk: .new(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('../system_accent_color/example'),
      ),
      classes: [
        'android.util.TypedValue',
        'android.content.Context',
        'android.content.res.Resources',
        'android.R',
      ],
    ),
    output: .new(
      dart: .new(
        path: packageRoot.resolve('lib/src/android_bindings.g.dart'),
        structure: .singleFile,
      ),
    ),
  );
  await generator.generate();
}
