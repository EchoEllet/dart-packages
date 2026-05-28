import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:is_ios_simulator/src/messages.g.dart';

class IosSimulatorDetection {
  IosSimulatorDetection({@visibleForTesting IosSimulatorDetectionApi? api})
    : _hostApi = api ?? IosSimulatorDetectionApi();

  final IosSimulatorDetectionApi _hostApi;

  bool? _cached;

  Future<bool> isIosSimulator() async {
    return _cached ?? (_cached = await _hostApi.isIosSimulator());
  }
}

IosSimulatorDetection _instance = IosSimulatorDetection();

Future<bool> isIosSimulator() => _instance.isIosSimulator();
