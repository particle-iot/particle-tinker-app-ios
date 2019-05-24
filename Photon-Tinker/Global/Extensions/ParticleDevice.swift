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
}




