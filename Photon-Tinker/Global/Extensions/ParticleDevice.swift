//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension ParticleDevice {
    func isRunningTinker() -> Bool {
        if (self.connected && self.functions.contains("digitalread") && self.functions.contains("digitalwrite") && self.functions.contains("analogwrite") && self.functions.contains("analogread")) {
            return true
        } else {
            return false
        }
    }

    func is3rdGen() -> Bool {
        return self.type == .argon || self.type == .boron || self.type == .xenon || self.type == .aSeries || self.type == .bSeries || self.type == .xSeries
    }

    func getName() -> String {
        return self.name ?? "<no name>"
    }

    func getInfoDetails() -> [String: Any] {
        var info: [String: Any] = [:]

        info["Type"] = self.type
        info["ID"] = self.id ?? "Unknown"
        info["Serial"] = self.serialNumber ?? "Unknown"
        info["Device OS"] = self.systemFirmwareVersion ?? "Unknown"
        if let lastHeard = self.lastHeard {
            info["Last Heard"] = DateFormatter.localizedString(from: lastHeard, dateStyle: .medium, timeStyle: .short)
        } else {
            info["Last Heard"] = "Never"
        }

        if (self.cellular) {
            info["IMEI"] = self.imei ?? "Unknown"
            info["Last ICCID"] = self.lastIccid ?? "Unknown"
        }

        return info
    }

    func getInfoDetailsOrder() -> [String] {
        if (self.cellular) {
            return ["Type", "ID", "Serial", "IMEI", "Last ICCID", "Device OS", "Last Heard"]
        } else {
            return ["Type", "ID", "Serial", "Device OS", "Last Heard"]    
        }
    }
}

extension ParticleDeviceType {
    func getImage() -> UIImage? {
        switch (self)
        {
            case .core:
                return UIImage(named: "imgDeviceCore")
            case .electron:
                return UIImage(named: "imgDeviceElectron")
            case .photon:
                return UIImage(named: "imgDevicePhoton")
            case .P1:
                return UIImage(named: "imgDeviceP1")
            case .raspberryPi:
                return UIImage(named: "imgDeviceRaspberryPi")
            case .redBearDuo:
                return UIImage(named: "imgDeviceRedBearDuo")
            case .bluz:
                return UIImage(named: "imgDeviceBluz")
            case .digistumpOak:
                return UIImage(named: "imgDeviceDigistumpOak")
            case .xenon:
                return UIImage(named: "imgDeviceXenon")
            case .argon:
                return UIImage(named: "imgDeviceArgon")
            case .boron:
                return UIImage(named: "imgDeviceBoron")
            case .xSeries:
                return UIImage(named: "imgDeviceXenon")
            case .aSeries:
                return UIImage(named: "imgDeviceArgon")
            case .bSeries:
                return UIImage(named: "imgDeviceBoron")
            default:
                return UIImage(named: "imgDeviceUnknown")
        }
    }

    func getIconColor() -> UIColor {
        switch (self)
        {
            case .electron:
                return UIColor(rgb: 0xFE432C)
            case .photon:
                return UIColor(rgb: 0xF9CB00)
            case .xenon, .argon, .boron, .bSeries, .aSeries, .xSeries:
                return UIColor(rgb: 0x2ECC71)
            default:
                return UIColor(rgb: 0x999990)
        }
    }

    func getIconText() -> String {
        switch (self)
        {
            case .core:
                return "C"
            case .electron:
                return "E"
            case .photon:
                return "P"
            case .P1:
                return "P"
            case .raspberryPi:
                return "R"
            case .redBearDuo:
                return "R"
            case .bluz:
                return "B"
            case .digistumpOak:
                return "D"
            case .xenon:
                return "X"
            case .argon:
                return "A"
            case .boron:
                return "B"
            case .xSeries:
                return "X"
            case .aSeries:
                return "A"
            case .bSeries:
                return "B"
            default:
                return " "
        }
    }

}




