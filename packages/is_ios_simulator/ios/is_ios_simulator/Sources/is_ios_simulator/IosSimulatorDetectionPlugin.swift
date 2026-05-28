import Foundation
import Flutter

public class IosSimulatorDetectionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let api: IosSimulatorDetectionApi = IosSimulatorDetectionApiImpl()
    IosSimulatorDetectionApiSetup.setUp(binaryMessenger: messenger, api: api)
  }
}
