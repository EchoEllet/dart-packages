import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/src/android_bindings.g.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: '../../../librelab_flutter',
      ),
      classes: [
        'android.util.TypedValue',
        'android.content.Context',
        'android.content.res.Resources',
        'android.R',
      ],
    ),
  );
}
