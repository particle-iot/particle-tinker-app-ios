//
//  AppDelegate.swift
//  Photon-Tinker
//
//  Created by Ido on 4/16/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

let ANALYTICS = 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        ParticleLogger.setLoggerLevel(.complete)
        ParticleLogger.setLoggerLevel(.debug, forControl: "ParticleCloud") //ignore spam from complete
        ParticleLogger.setLoggerLevel(.debug, forControl: "ParticleDevice") //ignore spam from complete
        #if DEBUG
            ParticleLogger.setLoggerLevel(.info, forControl: "Particle.DeviceListViewController") //ignore some noise after device list is loaded
            ParticleLogger.setIgnoreControls(["HandshakeManager", "MeshSetupBluetoothConnectionManager", "BluetoothConnection"])
        #endif

        LogList.startLogging()
        LogList.clearStaleLogs()

        #if !DEBUG
            Fabric.with([Crashlytics.self])
        #endif


        let SegmentConfiguration = SEGAnalyticsConfiguration(writeKey: segmentAnalyticsWriteKey)
        SegmentConfiguration.trackApplicationLifecycleEvents = true
        SegmentConfiguration.recordScreenViews = false

        SegmentConfiguration.use(SEGFirebaseIntegrationFactory.instance())
        SEGAnalytics.setup(with: SegmentConfiguration)
        
        ParticleCloud.sharedInstance().oAuthClientId = oAuthClientId
        ParticleCloud.sharedInstance().oAuthClientSecret = oAuthSecret
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().toolbarManageBehaviour = .byTag


        return true

    }
}

