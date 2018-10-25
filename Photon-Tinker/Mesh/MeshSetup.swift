//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth


class MeshSetup {
    static let LogBluetoothHandshakeManager = false
    static let LogBluetoothConnectionManager = false
    static let LogBluetoothConnection = false
    static let LogTransceiver = false
    static let LogUIManager = false
    static let LogFlowManager = true

    static let bluetoothScanTimeoutValue: DispatchTimeInterval = .seconds(10)
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

// TODO: should be globally reference not just for mesh
extension ParticleDeviceType : CustomStringConvertible {
    public var description: String {
        switch self {
            case .unknown : return "Unknown"
            case .core : return "Core"
            case .photon : return "Photon"
            case .P1 : return "P1"
            case .electron : return "Electron"
            case .raspberryPi : return "RaspberryPi"
            case .redBearDuo : return "RedBearDuo"
            case .bluz : return "Bluz"
            case .digistumpOak : return "DigistumpOak"
            case .ESP32 : return "ESP32"
            case .argon : return "Argon"
            case .boron : return "Boron"
            case .xenon : return "Xenon"
        }
    }

    init?(serialNumber: String) {
        if (serialNumber.lowercased().range(of: "xenh")?.lowerBound == serialNumber.startIndex) {
            self = .xenon
        } else if (serialNumber.lowercased().range(of: "argh")?.lowerBound == serialNumber.startIndex) {
            self = .argon
        } else if (serialNumber.lowercased().range(of: "b31k")?.lowerBound == serialNumber.startIndex) {
            self = .boron
        } else if (serialNumber.lowercased().range(of: "b40k")?.lowerBound == serialNumber.startIndex) {
            self = .boron
        } else {
            return nil
        }
    }
}