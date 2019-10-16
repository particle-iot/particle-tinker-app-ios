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
        if let name = self.name, name.count > 0 {
            return name
        } else {
            return "<no name>"
        }
    }

    func getInfoDetails() -> [String: Any] {
        var info: [String: Any] = [:]

        info["Type"] = self.type
        info["ID"] = self.id ?? "Unknown"
        info["Serial"] = self.serialNumber ?? "Unknown"
        info["Device OS"] = self.systemFirmwareVersion ?? "Unknown"
        info["Last IP Address"] = self.lastIPAdress ?? "Unknown"
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
            return ["Type", "ID", "Serial", "IMEI", "Last ICCID", "Device OS", "Last IP Address", "Last Heard"]
        } else {
            return ["Type", "ID", "Serial", "Device OS", "Last IP Address", "Last Heard"]    
        }
    }
}

extension ParticleDeviceType {
    func getImage() -> UIImage? {
        switch (self)
        {
            case .core:
                return UIImage(named: "ImgDeviceCore")
            case .electron:
                return UIImage(named: "ImgDeviceElectron")
            case .photon:
                return UIImage(named: "ImgDevicePhoton")
            case .P1:
                return UIImage(named: "ImgDeviceP1")
            case .raspberryPi:
                return UIImage(named: "ImgDeviceRaspberryPi")
            case .redBearDuo:
                return UIImage(named: "ImgDeviceRedBearDuo")
            case .bluz:
                return UIImage(named: "ImgDeviceBluz")
            case .digistumpOak:
                return UIImage(named: "ImgDeviceDigistumpOak")
            case .xenon:
                return UIImage(named: "ImgDeviceXenon")
            case .argon:
                return UIImage(named: "ImgDeviceArgon")
            case .boron:
                return UIImage(named: "ImgDeviceBoron")
            case .xSeries:
                return UIImage(named: "ImgDeviceXenon")
            case .aSeries:
                return UIImage(named: "ImgDeviceArgon")
            case .bSeries:
                return UIImage(named: "ImgDeviceBoron")
            default:
                return UIImage(named: "ImgDeviceUnknown")
        }
    }

    func getIconColor() -> UIColor {
        switch (self)
        {
            case .core:
                return UIColor(rgb: 0x76777A)
            case .electron:
                return UIColor(rgb: 0x00AE42)
            case .photon, .P1:
                return UIColor(rgb: 0xB31983)
            case .raspberryPi, .redBearDuo, .ESP32, .bluz:
                return UIColor(rgb: 0x76777A)
            case .argon, .aSeries:
                return UIColor(rgb: 0x00AEEF)
            case .boron, .bSeries:
                return UIColor(rgb: 0xED1C24)
            case .xenon, .xSeries:
                return UIColor(rgb: 0xF5A800)
            default:
                return UIColor(rgb: 0x76777A)
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
                return "1"
            case .raspberryPi:
                return "R"
            case .redBearDuo:
                return "D"
            case .ESP32:
                return "ES"
            case .bluz:
                return "BZ"
            case .xenon, .xSeries:
                return "X"
            case .argon, .aSeries:
                return "A"
            case .boron, .bSeries:
                return "B"
            default:
                return "?"
        }
    }

}




