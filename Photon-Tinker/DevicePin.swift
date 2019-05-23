//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

struct DevicePinsDefinition: Decodable {
    var platformId: Int
    var pins: [DevicePin]

    enum CodingKeys: String, CodingKey {
        case pins = "pins"
        case platformId = "deviceTypeId"
    }
}

struct DevicePin: Equatable {
    enum DevicePinSide: String, Decodable {
        case left = "LEFT"
        case right = "RIGHT"
    }

    var label: String
    var logicalName: String
    var side: DevicePinSide
    var functions: DevicePinFunction

    init(label: String, logicalName: String, side: DevicePinSide, functions: DevicePinFunction) {
        self.label = label
        self.logicalName = logicalName
        self.side = side
        self.functions = functions
    }

}

extension DevicePin: Decodable {
    enum CodingKeys: String, CodingKey {
        case label
        case logicalName = "tinkerName"
        case side = "column"
        case functions = "functions"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let label: String = try container.decode(String.self, forKey: .label)
        let logicalName: String = try container.decode(String.self, forKey: .logicalName)
        let side: DevicePinSide = try container.decode(DevicePinSide.self, forKey: .side)
        let functionStrings: [String] = try container.decode([String].self, forKey: .functions)

        var functions: DevicePinFunction = .none
        if (functionStrings.contains("DigitalRead")) {
            functions.update(with: .digitalRead)
        }

        if (functionStrings.contains("DigitalWrite")) {
            functions.update(with: .digitalWrite)
        }

        if (functionStrings.contains("AnalogRead")) {
            functions.update(with: .analogRead)
        }

        if (functionStrings.contains("AnalogWritePWM")) {
            functions.update(with: .analogWritePWM)
        }

        if (functionStrings.contains("AnalogWriteDAC")) {
            functions.update(with: .analogWriteDAC)
        }

        self.init(label: label, logicalName: logicalName, side: side, functions: functions)
    }
}

