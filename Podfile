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

    # iOS one-time-code (2FA) AutoFill: the ParticleSetup MFA screen never sets the
    # verification-code field's textContentType, so iOS won't offer the stored 2FA
    # token from the Passwords app. Patch it here — Pods/ is git-ignored, so this
    # reapplies on every `pod install` (locally and in CI).
    mfa = installer.sandbox.root + 'ParticleSetup/ParticleSetup/UI/ParticleUserMFAViewController.m'
    if File.exist?(mfa)
        src = File.read(mfa)
        if src.include?('UITextContentTypeOneTimeCode')
            Pod::UI.puts 'MFA oneTimeCode AutoFill already patched'
        else
            anchor = 'self.codeTextField.delegate = self;'
            if src.include?(anchor)
                src = src.sub(anchor, anchor + "\n    if (@available(iOS 12.0, *)) { self.codeTextField.textContentType = UITextContentTypeOneTimeCode; } // AutoFill 2FA code from the Passwords app")
                # CocoaPods marks pod sources read-only; make writable to apply the patch.
                File.chmod(0644, mfa)
                File.write(mfa, src)
                Pod::UI.puts 'Patched ParticleUserMFAViewController: oneTimeCode AutoFill'
            else
                Pod::UI.warn 'Could not patch MFA oneTimeCode: anchor not found (ParticleSetup may have changed)'
            end
        end
    else
        Pod::UI.warn 'ParticleUserMFAViewController.m not found; skipping oneTimeCode patch'
    end
end
