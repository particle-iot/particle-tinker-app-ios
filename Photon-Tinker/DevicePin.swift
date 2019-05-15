//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation


class DevicePin {

    enum DevicePinSide {
        case left
        case right
    }

    var label:String
    var logicalName:String
    var side:DevicePinSide
    var row:Int
    var availableFunctions:DevicePinFunction

    var value:Int
    var selectedFunction:DevicePinFunction = .none

    init(label: String, logicalName: String, side: DevicePinSide, row: Int, availableFunctions: DevicePinFunction) {
        self.label = label
        self.logicalName = logicalName
        self.side = side
        self.row = row
        self.availableFunctions = availableFunctions
        
        self.value = 0
    }

    func adjustValue(newValue: Int) {
        self.value = newValue;
    }
}

