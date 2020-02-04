//
// Created by Raimundas Sakalauskas on 2019-03-21.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

internal struct MeshSetupDevice {
    var type: ParticleDeviceType?
    var deviceId: String?

    var sim: MeshSetupSim?
    var setSimActive: Bool? //set by user
    var setSimDataLimit: Int? //set by user

    var credentials: MeshSetupPeripheralCredentials?
    var state: MeshSetupDeviceState = .none

    //used by control panel
    var name: String? //name stored in cloud (credentials has name of bluetooth network)
    var notes: String? //notes stored in cloud
    var networkRole: ParticleDeviceNetworkRole?

    var transceiver: MeshSetupProtocolTransceiver?

    //flags related to OTA Update
    var firmwareVersion: String?
    var ncpVersion: String?
    var ncpModuleVersion: Int?
    var ncpVersionReceived: Bool?
    var supportsCompressedOTAUpdate: Bool?
    var supportsMesh: Bool = false

    var firmwareFilesFlashed: Int?
    var firmwareUpdateProgress: Double?
    var ethernetDetectionFeature: Bool? //set by device
    var enableEthernetDetectionFeature: Bool? //set by user

    var claimCode: String?
    var isClaimed: Bool?
    var isSetupDone: Bool?

    var isListeningMode: Bool?
    var isCommissionerMode: Bool?


    var activeInternetInterface: MeshSetupNetworkInterfaceType?
    var hasInternetAddress: Bool?

    var networkInterfaces: [MeshSetupNetworkInterfaceEntry]?
    var joinerCredentials: (eui64: String, password: String)?

    var meshNetworkInfo: MeshSetupNetworkInfo?
    var meshNetworks: [MeshSetupNetworkInfo]?

    var wifiNetworkInfo: MeshSetupNewWifiNetworkInfo? //used in control panel
    var wifiNetworks: [MeshSetupNewWifiNetworkInfo]?
    var knownWifiNetworks: [MeshSetupKnownWifiNetworkInfo]? //used in control panel

    var bluetoothName: String? {
        get {
            return self.credentials?.name
        }
    }

    func hasActiveInternetInterface() -> Bool {
        return activeInternetInterface != nil
    }

    func getActiveNetworkInterfaceIdx() -> UInt32? {
        if let activeInterface = activeInternetInterface, let interfaces = networkInterfaces {
            for interface in interfaces {
                if interface.type == activeInterface {
                    return interface.index
                }
            }
        }
        return nil
    }
}

internal enum MeshSetupDeviceState: Int {
    case none = 0
    case credentialsSet
    case discovered
    case connected
    case ready
}


internal struct MeshSetupSim {
    var isExternal: Bool?
    var iccid: String?
    var active: Bool?
    var dataLimit: Int?
    var status: ParticleSimDetailedStatus?

    func iccidEnding() -> String? {
        if let iccid = self.iccid {
            let startIndex = iccid.index(iccid.endIndex, offsetBy: -4)
            return String(iccid.suffix(from: startIndex))
        }

        return nil
    }
}

internal struct MeshSetupPeripheralCredentials {
    var name: String
    var mobileSecret: String
}

// TODO: should be globally reference not just for mesh
extension ParticleDeviceType : CustomStringConvertible {
    public var description: String {
        switch self {
            case .unknown: return "Unknown"
            case .core: return "Core"
            case .photon: return "Photon"
            case .P1: return "P1"
            case .electron: return "Electron"
            case .raspberryPi: return "RaspberryPi"
            case .redBearDuo: return "RedBearDuo"
            case .bluz: return "Bluz"
            case .digistumpOak: return "DigistumpOak"
            case .ESP32: return "ESP32"
            case .argon: return "Argon"
            case .boron: return "Boron"
            case .bSoMCat1: return "B SoM CAT 1"
            case .xenon: return "Xenon"
            case .aSeries: return "A SoM"
            case .bSeries: return "B SoM"
            case .xSeries: return "X SoM"
            default: return "Unknown"
        }
    }

    public var bluetoothNamePrefix: String {
        switch self {
            case .argon: return "Argon"
            case .boron: return "Boron"
            case .xenon: return "Xenon"
            case .aSeries: return "Argon"
            case .bSeries: return "Boron"
            case .xSeries: return "Xenon"
            case .bSoMCat1: return "B5som"
            default: return ""
        }
    }

    static func requiresBattery(serialNumber: String) -> Bool {
        func isSNPrefix(prefix : String) -> Bool {
            return (serialNumber.lowercased().range(of: prefix)?.lowerBound == serialNumber.startIndex)
        }

        //boron 3g / bsom / b5som (b som cat1)
        return isSNPrefix(prefix: "b31") || isSNPrefix(prefix: "p002") || isSNPrefix(prefix: "p015")
    }
}
