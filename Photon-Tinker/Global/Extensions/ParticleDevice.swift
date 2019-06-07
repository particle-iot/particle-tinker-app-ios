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

    func getImage() -> UIImage? {
        switch (self.type)
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
}




