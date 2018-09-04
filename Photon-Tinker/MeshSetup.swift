//
//  ParticleCommon.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth


class MeshSetup {
    static let LogBluetoothHandshakeManager = true
    static let LogBluetoothConnectionManager = true
    static let LogBluetoothConnection = true
    static let LogTransceiver = true

    static let bluetoothScanTimeoutValue: TimeInterval = 20.0
    static let bluetoothSendTimeoutValue: TimeInterval = 15.0
    static let bluetoothSendTimeoutRetryCount: Int = 0

    static let particleMeshServiceUUID: CBUUID = CBUUID(string: "6FA90001-5C4E-48A8-94F4-8030546F36FC")

    static let particleMeshRXCharacterisiticUUID: CBUUID = CBUUID(string: "6FA90004-5C4E-48A8-94F4-8030546F36FC")
    static let particleMeshTXCharacterisiticUUID: CBUUID = CBUUID(string: "6FA90003-5C4E-48A8-94F4-8030546F36FC")
}

enum MeshSetupErrorSeverity {
    case Info //just some info for the user
    case Warning //something user should be informed
    case Error //can't continue at this point, but possible to solve
    case Fatal //can't continue and won't be able to solve
}

enum MeshSetupErrorAction {
    case Dialog
    case Pop
    case Fail
}

struct MeshSetupPeripheralCredentials {
    var name: String
    var mobileSecret: String
}

enum MeshSetupDeviceRole {
    case Joiner
    case Commissioner
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
}

func replaceMeshSetupStringTemplates(view: UIView, deviceType : ParticleDeviceType?, networkName : String?, deviceName : String?) {
    
    let subviews = view.subviews
    
    for subview in subviews {
        if subview is UILabel {
            let label = subview as! UILabel
            var newLabelString = label.text
            // TODO: retrieve info diffrently
            if let t = deviceType {
                newLabelString = label.text?.replacingOccurrences(of: "{{device}}", with: t.description)
            }

            if let n = networkName {
                newLabelString = newLabelString!.replacingOccurrences(of: "{{network}}", with: n)
            }

            if let d = deviceName {
                newLabelString = newLabelString!.replacingOccurrences(of: "{{deviceName}}", with: d)
            }

            label.text = newLabelString
        }
        
    }
}


