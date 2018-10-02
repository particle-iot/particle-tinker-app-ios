//
//  Keys.swift
//  Particle
//
//  Created by Ido Kleinman on 5/9/16.
//  Copyright © 2016 spark. All rights reserved.
//
//  Copy this file to Keys.swift and modify key values for production apps

import Foundation

//you can obtain this from https://app.segment.com/ by creating an iOS app source and copying API write key.
let segmentAnalyticsWriteKey = "segment-source-key"

//you can obtain this from https://console.particle.io/authentication
let oAuthClientId = "myapp-auth-client"
let oAuthSecret = "myapp-auth-secret"


#if DEBUG
    let launchDarkly = "mob-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
#else
    let launchDarkly = "mob-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
#endif
