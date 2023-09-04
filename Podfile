# Uncomment the next line to define a global platform for your project
#platform :ios, '.0'

target 'DemoSecureChat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DemoSecureChat

  pod 'SignalProtocolObjC'
  pod 'SignalProtocolC'
  pod 'CocoaLumberjack/Swift'
  pod 'Starscream', '~> 4.0.4'
  pod 'CocoaMQTT', :path => 'DevelopmentPods/COCOAMQTT/'
  pod 'CryptoSwift', '~> 1.4.1'
  pod 'KeychainAccess'

target 'DemoSecureChatTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DemoSecureChatUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = "YES"      
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
