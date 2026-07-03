import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final Uri packageRoot = Platform.script.resolve('../');

  FfiGenerator(
    output: Output(
      dartFile: packageRoot.resolve('lib/src/ffi_bindings.g.dart'),
      style: const DynamicLibraryBindings(
        wrapperName: 'AppKitFFI',
        wrapperDocComment: 'Bindings for NSColor (macOS accent color).',
      ),
    ),
    headers: Headers(
      entryPoints: <Uri>[
        Uri.file(
          '$macSdkPath/System/Library/Frameworks/AppKit.framework/Headers/AppKit.h',
        ),
      ],
    ),
    objectiveC: ObjectiveC(
      interfaces: Interfaces(
        include: (Declaration d) =>
            <String>{'NSColor', 'NSColorSpace'}.contains(d.originalName),

        includeMember: (Declaration d, String member) {
          return switch (d.originalName) {
            'NSColor' => <String>{
              'controlAccentColor',
              'colorUsingColorSpace:',
              'redComponent',
              'greenComponent',
              'blueComponent',
              'alphaComponent',
            }.contains(member),

            'NSColorSpace' => <String>{'deviceRGBColorSpace'}.contains(member),

            _ => false,
          };
        },
      ),
    ),
  ).generate();
}
