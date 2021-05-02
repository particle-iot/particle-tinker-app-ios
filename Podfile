source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'Particle' do
    pod 'Particle-SDK'
    pod 'ParticleSetup'
    pod 'Zip', '~> 1.1'
    pod 'SwiftProtobuf', '~> 1.0'
    pod 'MBProgressHUD', '~> 0.9'
    pod 'RMessage'
    pod 'ASValueTrackingSlider'
    pod 'DateTools'
    pod 'IQKeyboardManager'
    pod 'YCTutorialBox'
    pod 'Crashlytics'
    pod 'Analytics'
    pod 'Segment-Firebase'
    pod 'Reveal-SDK', :configurations => ['Debug']
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
            end
        end
    end
end

