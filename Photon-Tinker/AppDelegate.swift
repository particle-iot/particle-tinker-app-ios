//
//  AppDelegate.swift
//  Photon-Tinker
//
//  Copyright (c) 2015 particle. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ParticleLogger.setLoggerLevel(.complete)
        ParticleLogger.setLoggerLevel(.debug, forControl: "ParticleCloud") //ignore spam from complete
        ParticleLogger.setLoggerLevel(.debug, forControl: "ParticleDevice") //ignore spam from complete
        #if DEBUG
            ParticleLogger.setLoggerLevel(.info, forControl: "Particle.DeviceListViewController") //ignore some noise after device list is loaded
            ParticleLogger.setIgnoreControls(["HandshakeManager", "Gen3SetupBluetoothConnectionManager", "BluetoothConnection"])
        #endif

        LogList.startLogging()
        LogList.clearStaleLogs()

        NSLog("ParticleCloud.sharedInstance().accessToken = \(ParticleCloud.sharedInstance().accessToken as Optional)")
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device: %@", withParameters: getVaList([UIDevice.modelName]))
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "App Version: v%@b%@", withParameters: getVaList([Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String]))
        ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "iOS Version: %@", withParameters: getVaList([UIDevice.current.systemVersion]))

        ParticleCloud.sharedInstance().oAuthClientId = oAuthClientId
        ParticleCloud.sharedInstance().oAuthClientSecret = oAuthSecret

        #if !DEBUG
            // Production safeguard: release builds must always talk to the production
            // cloud (https://api.particle.io). The custom API base URL is persisted in
            // NSUserDefaults, so clear any value (e.g. a staging URL set via the hidden
            // developer override on a debug build) to guarantee a release build can
            // never accidentally point at staging.
            ParticleCloud.sharedInstance().customAPIBaseURL = nil
        #endif

        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().toolbarManageBehavior = .byTag


        return true

    }
}

