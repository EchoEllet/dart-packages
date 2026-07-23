/// Detects whether the application is running on an iOS Simulator.
library;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:is_ios_simulator/src/messages.g.dart';

/// Provides iOS Simulator detection.
class IosSimulatorDetection {
  /// Creates an iOS Simulator detection instance.
  ///
  /// The [api] parameter is exposed for testing.
  IosSimulatorDetection({@visibleForTesting IosSimulatorDetectionApi? api})
    : _hostApi = api ?? IosSimulatorDetectionApi();

  final IosSimulatorDetectionApi _hostApi;

  bool? _cached;

  /// Returns whether the application is running on an iOS Simulator.
  ///
  /// The result is cached for this instance after the first call.
  ///
  /// Always returns `false` on non-iOS platforms.
  Future<bool> isIosSimulator() async {
    if (!Platform.isIOS) {
      return false;
    }
    return _cached ?? (_cached = await _hostApi.isIosSimulator());
  }
}

final _instance = IosSimulatorDetection();

/// Returns whether the application is running on an iOS Simulator.
///
/// The result is cached after the first call.
Future<bool> isIosSimulator() => _instance.isIosSimulator();
