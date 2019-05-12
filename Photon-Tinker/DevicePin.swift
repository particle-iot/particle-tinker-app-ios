//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum DevicePinSide {
    case left
    case right
}

struct DevicePinFunction: OptionSet {
    let rawValue: Int

    static let none           = DevicePinFunction(rawValue: 0)
    static let digitalRead    = DevicePinFunction(rawValue: 1 << 0)
    static let digitalWrite   = DevicePinFunction(rawValue: 1 << 1)
    static let analogRead     = DevicePinFunction(rawValue: 1 << 2)
    static let analogWrite    = DevicePinFunction(rawValue: 1 << 3)
    static let analogWriteDAC = DevicePinFunction(rawValue: 1 << 4)

    static let all: DevicePinFunction = [.digitalRead, .digitalWrite, .analogRead, .analogWrite, .analogWriteDAC]

    func isAnalog() -> Bool {
        return self == DevicePinFunction.analogRead || self == DevicePinFunction.analogWrite || self == DevicePinFunction.analogWriteDAC
    }

    func isDigital() -> Bool {
        return self == DevicePinFunction.digitalRead || self == DevicePinFunction.digitalWrite
    }

    func isNothing() -> Bool {
        return self == DevicePinFunction.none
    }

    func getColor() -> UIColor {
        switch self {
            case DevicePinFunction.digitalRead:
                return UIColor(red: 0.0, green: 0.67, blue: 0.93, alpha: 1.0)
            case DevicePinFunction.digitalWrite:
                return UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0)
            case DevicePinFunction.analogRead:
                return UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 1.0)
            case DevicePinFunction.analogWrite:
                return UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)
            case DevicePinFunction.analogWriteDAC:
                return UIColor(red: 0.95, green: 0.6, blue: 0.06, alpha: 1.0)
            default:
                return UIColor.clear
        }
    }

    func getName() -> String? {
        switch self {
            case DevicePinFunction.digitalRead:
                return "digitalread"
            case DevicePinFunction.digitalWrite:
                return "digitalwrite"
            case DevicePinFunction.analogRead:
                return "analogread"
            case DevicePinFunction.analogWrite, DevicePinFunction.analogWriteDAC:
                return "analogwrite"
            default:
                return nil
        }
    }
}



class DevicePin {
    var label:String
    var logicalName:String
    var side:DevicePinSide
    var row:Int
    var availableFunctions:DevicePinFunction

    var value:UInt?
    var selectedFunction:DevicePinFunction = .none

    init(label: String, logicalName: String, side: DevicePinSide, row: Int, availableFunctions: DevicePinFunction) {
        self.label = label
        self.logicalName = logicalName
        self.side = side
        self.row = row
        self.availableFunctions = availableFunctions
    }

    func resetValue() {
        self.value = nil
    }

    func adjustValue(newValue: UInt) {
        self.value = newValue;
    }
}

