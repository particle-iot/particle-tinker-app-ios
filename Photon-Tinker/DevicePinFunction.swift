//
// Created by Raimundas Sakalauskas on 2019-05-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

struct DevicePinFunction: OptionSet {
    enum Constants {
        static var analogReadMaxValue: CGFloat = 4095.0
        static var analogWritePWMMaxValue: CGFloat = 255.0
        static var analogWriteDACMaxValue: CGFloat = 4095.0
    }

    let rawValue: Int

    static let none                     = DevicePinFunction(rawValue: 0)
    static let digitalRead              = DevicePinFunction(rawValue: 1 << 0)
    static let digitalWrite             = DevicePinFunction(rawValue: 1 << 1)
    static let analogRead               = DevicePinFunction(rawValue: 1 << 2)
    static let analogWritePWM           = DevicePinFunction(rawValue: 1 << 3)
    static let analogWriteDAC           = DevicePinFunction(rawValue: 1 << 4)
    static let all: DevicePinFunction   = [.digitalRead, .digitalWrite, .analogRead, .analogWritePWM, .analogWriteDAC]

    static func getColor(function: DevicePinFunction) -> UIColor {
        switch function {
            case DevicePinFunction.digitalRead:
                return UIColor(rgb: 0x0075C9)
            case DevicePinFunction.digitalWrite:
                return UIColor(rgb: 0xED1C24)
            case DevicePinFunction.analogRead:
                return UIColor(rgb: 0x00AE42)
            case DevicePinFunction.analogWritePWM:
                return UIColor(rgb: 0xFFCD00)
            case DevicePinFunction.analogWriteDAC:
                return UIColor(rgb: 0xF5A800)
            default:
                return UIColor.clear
        }
    }


    func isAnalog() -> Bool {
        return self == DevicePinFunction.analogRead || self == DevicePinFunction.analogWritePWM || self == DevicePinFunction.analogWriteDAC
    }

    func isDigital() -> Bool {
        return self == DevicePinFunction.digitalRead || self == DevicePinFunction.digitalWrite
    }

    func isRead() -> Bool {
        return self == DevicePinFunction.analogRead || self == DevicePinFunction.digitalRead
    }

    func isWrite() -> Bool {
        return self == DevicePinFunction.digitalWrite || self == DevicePinFunction.analogWritePWM || self == DevicePinFunction.analogWriteDAC
    }

    func getColor() -> UIColor {
        return DevicePinFunction.getColor(function: self)
    }

    func getLogicalName() -> String? {
        switch self {
            case DevicePinFunction.digitalRead:
                return "digitalread"
            case DevicePinFunction.digitalWrite:
                return "digitalwrite"
            case DevicePinFunction.analogRead:
                return "analogread"
            case DevicePinFunction.analogWritePWM, DevicePinFunction.analogWriteDAC:
                return "analogwrite"
            default:
                return nil
        }
    }

    func getName() -> String? {
        switch self {
            case DevicePinFunction.digitalRead:
                return TinkerStrings.Tinker.Function.DigitalRead
            case DevicePinFunction.digitalWrite:
                return TinkerStrings.Tinker.Function.DigitalWrite
            case DevicePinFunction.analogRead:
                return TinkerStrings.Tinker.Function.AnalogRead
            case DevicePinFunction.analogWritePWM, DevicePinFunction.analogWriteDAC:
                return TinkerStrings.Tinker.Function.AnalogWrite
            default:
                return nil
        }
    }
}
