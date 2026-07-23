/// Provides iOS Simulator detection.
class IosSimulatorDetection {
  /// Creates an iOS Simulator detection instance.
  IosSimulatorDetection();

  /// Returns whether the application is running on an iOS Simulator.
  ///
  /// Always returns `false` on web.
  Future<bool> isIosSimulator() async => false;
}

/// Returns whether the application is running on an iOS Simulator.
///
/// Always returns `false` on web.
Future<bool> isIosSimulator() async => false;
