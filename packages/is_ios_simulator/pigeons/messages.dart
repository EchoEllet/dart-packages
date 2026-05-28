import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/is_ios_simulator/Sources/is_ios_simulator/Messages.g.swift',
    dartPackageName: 'is_ios_simulator',
  ),
)
@HostApi()
abstract class IosSimulatorDetectionApi {
  bool isIosSimulator();
}
