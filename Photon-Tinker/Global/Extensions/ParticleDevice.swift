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
        return self.type == .argon || self.type == .boron || self.type == .xenon || self.type == .aSeries || self.type == .bSeries || self.type == .xSeries || self.type == .b5SoM
    }

    func getName() -> String {
        if let name = self.name, name.count > 0 {
            return name
        } else {
            return TinkerStrings.Device.NoName
        }
    }

    func getInfoDetails() -> [String: Any] {
        var info: [String: Any] = [:]

        info[TinkerStrings.InfoSlider.DeviceCell.DeviceType] = self.type
        info[TinkerStrings.InfoSlider.DeviceCell.DeviceId] = self.id ?? TinkerStrings.InfoSlider.DeviceCell.Unknown
        info[TinkerStrings.InfoSlider.DeviceCell.Serial] = self.serialNumber ?? TinkerStrings.InfoSlider.DeviceCell.Unknown
        info[TinkerStrings.InfoSlider.DeviceCell.DeviceOS] = self.systemFirmwareVersion ?? TinkerStrings.InfoSlider.DeviceCell.Unknown
        info[TinkerStrings.InfoSlider.DeviceCell.LastIPAddress] = self.lastIPAdress ?? TinkerStrings.InfoSlider.DeviceCell.Unknown
        if let lastHeard = self.lastHeard {
            info[TinkerStrings.InfoSlider.DeviceCell.LastHeard] = DateFormatter.localizedString(from: lastHeard, dateStyle: .medium, timeStyle: .short)
        } else {
            info[TinkerStrings.InfoSlider.DeviceCell.LastHeard] = TinkerStrings.InfoSlider.DeviceCell.Never
        }

        if (self.cellular) {
            info[TinkerStrings.InfoSlider.DeviceCell.IMEI] = self.imei ?? TinkerStrings.InfoSlider.DeviceCell.Unknown
            info[TinkerStrings.InfoSlider.DeviceCell.LastICCID] = self.lastIccid ?? TinkerStrings.InfoSlider.DeviceCell.Unknown
        }

        return info
    }

    func getInfoDetailsOrder() -> [String] {
        if (self.cellular) {
            return [TinkerStrings.InfoSlider.DeviceCell.DeviceType,
                    TinkerStrings.InfoSlider.DeviceCell.DeviceId,
                    TinkerStrings.InfoSlider.DeviceCell.Serial,
                    TinkerStrings.InfoSlider.DeviceCell.IMEI,
                    TinkerStrings.InfoSlider.DeviceCell.LastICCID,
                    TinkerStrings.InfoSlider.DeviceCell.DeviceOS,
                    TinkerStrings.InfoSlider.DeviceCell.LastIPAddress,
                    TinkerStrings.InfoSlider.DeviceCell.LastHeard]
        } else {
            return [TinkerStrings.InfoSlider.DeviceCell.DeviceType,
                    TinkerStrings.InfoSlider.DeviceCell.DeviceId,
                    TinkerStrings.InfoSlider.DeviceCell.Serial,
                    TinkerStrings.InfoSlider.DeviceCell.DeviceOS,
                    TinkerStrings.InfoSlider.DeviceCell.LastIPAddress,
                    TinkerStrings.InfoSlider.DeviceCell.LastHeard]
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
            case .b5SoM:
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
            case .boron, .bSeries, .b5SoM:
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
            case .boron, .bSeries, .b5SoM:
                return "B"
            default:
                return "?"
        }
    }

}




