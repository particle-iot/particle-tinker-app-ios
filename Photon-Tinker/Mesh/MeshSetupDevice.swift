//
// Created by Raimundas Sakalauskas on 2019-03-21.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

internal struct MeshSetupDevice {
    var type: ParticleDeviceType?
    var deviceId: String?

    var sim: MeshSetupSim?
    var setSimActive: Bool? //set by user
    var setSimDataLimit: Int? //set by user

    var credentials: MeshSetupPeripheralCredentials?

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

//this has to be class because mutating keyword cannot be used together with @escaping closures.
internal struct MeshSetupDataMatrix {
    var serialNumber: String
    var mobileSecret: String

    private(set) public var type: ParticleDeviceType?

    var matrixString: String {
        return "\(serialNumber) \(mobileSecret)"
    }

    init?(dataMatrixString: String, deviceType: ParticleDeviceType? = nil) {
        let regex = try! NSRegularExpression(pattern: "([a-zA-Z0-9]{15})[ ]{1}([a-zA-Z0-9]{12,15})")
        let nsString = dataMatrixString as NSString
        let results = regex.matches(in: dataMatrixString, range: NSRange(location: 0, length: nsString.length))

        if (results.count > 0) {
            let arr = dataMatrixString.split(separator: " ")
            serialNumber = String(arr[0])//"12345678abcdefg"
            mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
            type = (deviceType != nil) ? deviceType : ParticleDeviceType(serialNumber: serialNumber)
        } else {
            return nil
        }
    }

    init(serialNumber: String, mobileSecret: String, deviceType: ParticleDeviceType? = nil) {
        self.serialNumber = serialNumber
        self.mobileSecret = mobileSecret
        self.type = (deviceType != nil) ? deviceType : ParticleDeviceType(serialNumber: serialNumber)
    }

    func isMobileSecretValid() -> Bool {
        return mobileSecret.count == 15
    }

    func isDeviceTypeKnown() -> Bool {
        return type != nil
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
            case .aSeries : return "A Series"
            case .bSeries : return "B Series"
            case .xSeries : return "X Series"
        }
    }

    public var bluetoothNamePrefix: String {
        switch self {
            case .argon : return "Argon"
            case .boron : return "Boron"
            case .xenon : return "Xenon"
            case .aSeries : return "Argon"
            case .bSeries : return "Boron"
            case .xSeries : return "Xenon"
            default: return ""
        }
    }

    static func requiresBattery(serialNumber: String) -> Bool {
        func isSNPrefix(prefix : String) -> Bool {
            return (serialNumber.lowercased().range(of: prefix)?.lowerBound == serialNumber.startIndex)
        }

        return isSNPrefix(prefix: "b31") || isSNPrefix(prefix: "p002")
    }

    init?(serialNumber: String) {
        func isSNPrefix(prefix : String) -> Bool {
            return (serialNumber.lowercased().range(of: prefix)?.lowerBound == serialNumber.startIndex)
        }

        if isSNPrefix(prefix: "xenh") || isSNPrefix(prefix: "xenk") {
            self = .xenon
        } else if isSNPrefix(prefix: "arnh") || isSNPrefix(prefix: "arnk") || isSNPrefix(prefix: "argh") {
            self = .argon
        } else if isSNPrefix(prefix: "b40h") || isSNPrefix(prefix: "b31h") || isSNPrefix(prefix: "b40k") || isSNPrefix(prefix: "b31k") {
            self = .boron
        } else if isSNPrefix(prefix: "p001") || isSNPrefix(prefix: "p002") {
            self = .bSeries
        } else if isSNPrefix(prefix: "p003") {
            self = .aSeries
        } else if isSNPrefix(prefix: "p004") {
            self = .xSeries
        } else {
            return nil
        }
    }
}
