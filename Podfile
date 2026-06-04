source 'https://cdn.cocoapods.org/'

platform :ios, '15.0'

target 'Particle' do
    pod 'Particle-SDK'
    pod 'ParticleSetup'
    pod 'Zip', '~> 2.1'
    pod 'SwiftProtobuf', '~> 1.0'
    pod 'MBProgressHUD', '~> 1.2'
    pod 'RMessage'
    pod 'ASValueTrackingSlider'
    pod 'DateTools'
    pod 'IQKeyboardManager', '~> 6.5'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            # Bitcode was removed in Xcode 14+
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            # Old pods predate arm64 simulator excludes / module settings
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        end
    end
end
