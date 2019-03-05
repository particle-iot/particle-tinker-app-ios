//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureCorrectEthernetFeatureStatus: MeshSetupStep {
    override func start() {
        context.targetDevice.transceiver!.sendGetFeature(feature: .ethernetDetection) { result, enabled in
            self.log("targetDevice.sendGetFeature: \(result.description()) enabled: \(enabled as Optional)")
            self.log("self.targetDevice.enableEthernetFeature = \(self.context.targetDevice.enableEthernetFeature)")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                if (self.context.targetDevice.enableEthernetFeature == enabled) {
                    self.stepCompleted()
                } else {
                    self.setCorrectEthernetFeatureStatus()
                }
            } else if (result == .NOT_SUPPORTED) {
                self.stepCompleted()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }

    }

    func setCorrectEthernetFeatureStatus() {
        context.targetDevice.transceiver!.sendSetFeature(feature: .ethernetDetection, enabled: self.context.targetDevice.enableEthernetFeature!) { result  in
            self.log("targetDevice.sendSetFeature: \(result.description())")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.prepareForTargetDeviceReboot()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    func prepareForTargetDeviceReboot() {
        context.targetDevice.transceiver!.sendSetStartupMode(startInListeningMode: true) { result in
            self.log("targetDevice.sendSetStartupMode: \(result.description())")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.sendDeviceReset()
            } else if (result == .NOT_SUPPORTED) {
                self.sendDeviceReset()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func sendDeviceReset() {
        context.targetDevice.transceiver!.sendSystemReset() { result  in
            self.log("targetDevice.sendSystemReset: \(result.description())")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                //if all is fine, connection will be dropped and the setup will return few steps in dropped connection handler
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        self.log("force reconnect to device")

        let step = self.context.stepDelegate.rewindTo(self, step: StepConnectToTargetDevice.self) as! StepConnectToTargetDevice
        step.reconnectAfterForcedReboot = true
        step.reconnectAfterForcedRebootRetry = 1

        return true
    }

}
