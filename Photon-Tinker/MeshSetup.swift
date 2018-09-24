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
    static let LogBluetoothHandshakeManager = false
    static let LogBluetoothConnectionManager = false
    static let LogBluetoothConnection = false
    static let LogTransceiver = false
    static let LogUIManager = false
    static let LogFlowManager = true

    static let bluetoothScanTimeoutValue: DispatchTimeInterval = .seconds(10)
    static let bluetoothSendTimeoutValue: DispatchTimeInterval = .seconds(15)
    static let deviceObtainedIPTimeout: Double = 15.0
    static let deviceConnectToCloudTimeout: Double = 45.0
    static let deviceGettingClaimedTimeout: Double = 45.0
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

struct MeshSetupDataMatrix {
    var serialNumber: String
    var mobileSecret: String

    init?(dataMatrixString: String) {
        let regex = try! NSRegularExpression(pattern: "([a-zA-Z0-9]{15})[ ]{1}([a-zA-Z0-9]{15})")
        let nsString = dataMatrixString as NSString
        let results = regex.matches(in: dataMatrixString, range: NSRange(location: 0, length: nsString.length))

        if (results.count > 0) {
            let arr = dataMatrixString.split(separator: " ")
            serialNumber = String(arr[0])//"12345678abcdefg"
            mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        } else {
            return nil
        }
    }
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
        if (serialNumber.lowercased().range(of: "xen")?.lowerBound == serialNumber.startIndex) {
            self = .xenon
        } else if (serialNumber.lowercased().range(of: "arg")?.lowerBound == serialNumber.startIndex) {
            self = .argon
        } else if (serialNumber.lowercased().range(of: "brn")?.lowerBound == serialNumber.startIndex) {
            self = .boron
        } else {
            return nil
        }
    }
}

func replaceMeshSetupStringTemplates(string: String, deviceType : String? = nil, networkName : String? = nil, deviceName : String? = nil) -> String {
    var string = string

    if let t = deviceType {
        string = string.replacingOccurrences(of: "{{device}}", with: t.description)
    }

    if let n = networkName {
        string = string.replacingOccurrences(of: "{{network}}", with: n)
    }

    if let d = deviceName {
        string = string.replacingOccurrences(of: "{{deviceName}}", with: d)
    }

    return string
}

func replaceMeshSetupStringTemplates(view: UIView, deviceType : String? = nil, networkName : String? = nil, deviceName : String? = nil) {
    
    let subviews = view.subviews
    
    for subview in subviews {
        if subview is UILabel {
            let label = subview as! UILabel
            var newLabelString = label.text

            if let t = deviceType {
                newLabelString = label.text?.replacingOccurrences(of: "{{device}}", with: t)
            }

            if let n = networkName {
                newLabelString = newLabelString!.replacingOccurrences(of: "{{network}}", with: n)
            }

            if let d = deviceName {
                newLabelString = newLabelString!.replacingOccurrences(of: "{{deviceName}}", with: d)
            }

            label.text = newLabelString
        } else if (subview is UIView) {
            replaceMeshSetupStringTemplates(view: subview, deviceType: deviceType, networkName: networkName, deviceName: deviceName)
        }
    }
}


