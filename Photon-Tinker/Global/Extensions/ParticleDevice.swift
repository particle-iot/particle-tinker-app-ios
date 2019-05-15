//
// Created by Raimundas Sakalauskas on 2019-05-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension ParticleDevice {
    private struct AssociatedKeys {
        static var pinsAssociatedObjectHandle: UInt8 = 0
    }

    var pins:[DevicePin]? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pinsAssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.pinsAssociatedObjectHandle) as? [DevicePin] else {
                return nil
            }
            return value
        }
    }

    func resetPins() {
        if let pins = pins {
            for pin in pins {
                pin.selectedFunction = .none
                pin.value = 0
            }
        }
    }


    func configurePins() {
        var a0, a1, a2, a3, a4, a5, a6, a7: DevicePin!
        var d0, d1, d2, d3, d4, d5, d6, d7: DevicePin!


        switch self.type {
            case .core:
                a0 = DevicePin(label:"A0", logicalName:"A0", side:.left, row:7, availableFunctions:.all)
                a1 = DevicePin(label:"A1", logicalName:"A1", side:.left, row:6, availableFunctions:.all)
                a2 = DevicePin(label:"A2", logicalName:"A2", side:.left, row:5, availableFunctions:.all)
                a3 = DevicePin(label:"A3", logicalName:"A3", side:.left, row:4, availableFunctions:[.digitalRead, .digitalWrite, .analogRead])
                a4 = DevicePin(label:"A4", logicalName:"A4", side:.left, row:3, availableFunctions:[.digitalRead, .digitalWrite, .analogRead])
                a5 = DevicePin(label:"A5", logicalName:"A5", side:.left, row:2, availableFunctions:.all)
                a6 = DevicePin(label:"A6", logicalName:"A6", side:.left, row:1, availableFunctions:.all)
                a7 = DevicePin(label:"A7", logicalName:"A7", side:.left, row:0, availableFunctions:.all)

                d0 = DevicePin(label:"D0", logicalName:"D0", side:.right, row:7, availableFunctions:[.digitalRead, .digitalWrite, .analogWrite])
                d1 = DevicePin(label:"D1", logicalName:"D1", side:.right, row:6, availableFunctions:[.digitalRead, .digitalWrite, .analogWrite])
                d2 = DevicePin(label:"D2", logicalName:"D2", side:.right, row:5, availableFunctions:[.digitalRead, .digitalWrite])
                d3 = DevicePin(label:"D3", logicalName:"D3", side:.right, row:4, availableFunctions:[.digitalRead, .digitalWrite])
                d4 = DevicePin(label:"D4", logicalName:"D4", side:.right, row:3, availableFunctions:[.digitalRead, .digitalWrite])
                d5 = DevicePin(label:"D5", logicalName:"D5", side:.right, row:2, availableFunctions:[.digitalRead, .digitalWrite])
                d6 = DevicePin(label:"D6", logicalName:"D6", side:.right, row:1, availableFunctions:[.digitalRead, .digitalWrite])
                d7 = DevicePin(label:"D7", logicalName:"D7", side:.right, row:0, availableFunctions:[.digitalRead, .digitalWrite])
//            case .argon, .boron, .xenon:
//                break

            default: //.photon, .electron
                a0 = DevicePin(label:"A0", logicalName:"A0", side:.left, row:7, availableFunctions:[.digitalRead, .digitalWrite, .analogRead])
                a1 = DevicePin(label:"A1", logicalName:"A1", side:.left, row:6, availableFunctions:[.digitalRead, .digitalWrite, .analogRead])
                a2 = DevicePin(label:"A2", logicalName:"A2", side:.left, row:5, availableFunctions:[.digitalRead, .digitalWrite, .analogRead])
                a3 = DevicePin(label:"A3", logicalName:"A3", side:.left, row:4, availableFunctions:[.digitalRead, .digitalWrite, .analogRead, .analogWriteDAC])
                a4 = DevicePin(label:"A4", logicalName:"A4", side:.left, row:3, availableFunctions:[.all]) 
                a5 = DevicePin(label:"A5", logicalName:"A5", side:.left, row:2, availableFunctions:[.all]) 
                a6 = DevicePin(label:"DAC", logicalName:"A6", side:.left, row:1, availableFunctions:[.digitalRead, .digitalWrite, .analogRead, .analogWriteDAC])
                a7 = DevicePin(label:"WKP", logicalName:"A7", side:.left, row:0, availableFunctions:[.all])

                d0 = DevicePin(label:"D0", logicalName:"D0", side:.right, row:7, availableFunctions:[.digitalRead, .digitalWrite, .analogWrite])
                d1 = DevicePin(label:"D1", logicalName:"D1", side:.right, row:6, availableFunctions:[.digitalRead, .digitalWrite, .analogWrite])
                d2 = DevicePin(label:"D2", logicalName:"D2", side:.right, row:5, availableFunctions:[.digitalRead, .digitalWrite, .analogWrite])
                d3 = DevicePin(label:"D3", logicalName:"D3", side:.right, row:4, availableFunctions:[.digitalRead, .digitalWrite, .analogWrite]) 
                d4 = DevicePin(label:"D4", logicalName:"D4", side:.right, row:3, availableFunctions:[.digitalRead, .digitalWrite]) 
                d5 = DevicePin(label:"D5", logicalName:"D5", side:.right, row:2, availableFunctions:[.digitalRead, .digitalWrite])
                d6 = DevicePin(label:"D6", logicalName:"D6", side:.right, row:1, availableFunctions:[.digitalRead, .digitalWrite])
                d7 = DevicePin(label:"D7", logicalName:"D7", side:.right, row:0, availableFunctions:[.digitalRead, .digitalWrite])
                break
        }

        self.pins = [a0, a1, a2, a3, a4, a5, a6, a7, d0, d1, d2, d3, d4, d5, d6, d7];
    }

    func updatePin(pin: String, function: DevicePinFunction, value: Int?, success: @escaping (_ value: Int) -> Void, failure: @escaping (_ error: String?) -> Void) {

        guard let name = function.getName(), let value = value else {
            fatalError("unknown function")
        }

        var args:[Any] = [pin]

        switch function {
            case .analogWriteDAC, .analogWrite:
                args.append(NSNumber(value: value))
            case .digitalWrite:
                args.append(value != 0 ? "HIGH" : "LOW")
            default:
                break
        }

        callFunction(name, withArguments: args) { returnValue, error in
            if error == nil {
                success(returnValue?.intValue ?? 0)
            } else {
                failure(error?.localizedDescription)
            }
        }
    }

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




