//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth


class MeshSetup {
    static let bluetoothScanTimeoutValue: DispatchTimeInterval = .seconds(15)
    static let bluetoothSendTimeoutValue: DispatchTimeInterval = .seconds(15)
    static let deviceObtainedIPTimeout: Double = 15.0
    static let deviceObtainedIPCellularTimeout: Double = 90.0
    static let deviceConnectToCloudTimeout: Double = 45.0
    static let deviceGettingClaimedTimeout: Double = 45.0
    static let bluetoothSendTimeoutRetryCount: Int = 0
    static let activateSimRetryCount: Int = 2

    static let particleMeshServiceUUID: CBUUID = CBUUID(string: "6FA90001-5C4E-48A8-94F4-8030546F36FC")

    static let particleMeshRXCharacterisiticUUID: CBUUID = CBUUID(string: "6FA90004-5C4E-48A8-94F4-8030546F36FC")
    static let particleMeshTXCharacterisiticUUID: CBUUID = CBUUID(string: "6FA90003-5C4E-48A8-94F4-8030546F36FC")
}

