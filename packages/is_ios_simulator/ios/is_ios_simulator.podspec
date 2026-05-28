#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint is_ios_simulator.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'is_ios_simulator'
  s.version          = '0.0.1'
  s.summary          = 'Checks whether the app is running in iOS simulator'
  s.description      = <<-DESC
Checks whether the app is running in the iOS Simulator or on a physical device using #if targetEnvironment(simulator)
                       DESC
  s.homepage         = 'https://github.com/EchoEllet/dart-packages/tree/main/packages/is_ios_simulator'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'EchoEllet' => 'https://github.com/EchoEllet/dart-packages' }
  s.source           = { :http => 'https://github.com/EchoEllet/dart-packages/tree/main/packages/is_ios_simulator' }
  s.source_files = 'is_ios_simulator/Sources/is_ios_simulator/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.resource_bundles = {'is_ios_simulator_privacy' => ['is_ios_simulator/Sources/is_ios_simulator/Resources/PrivacyInfo.xcprivacy']}
end