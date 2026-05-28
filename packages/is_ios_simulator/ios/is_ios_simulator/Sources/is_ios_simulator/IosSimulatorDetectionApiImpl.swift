class IosSimulatorDetectionApiImpl: IosSimulatorDetectionApi {
    func isIosSimulator() throws -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
