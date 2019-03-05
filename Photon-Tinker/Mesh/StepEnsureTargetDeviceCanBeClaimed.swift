//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureTargetDeviceCanBeClaimed: MeshSetupStep {

    override func start() {
        if (self.context.targetDevice.deviceId == nil) {
            self.getDeviceId()
        } else if (self.context.targetDevice.isClaimed == nil) {
            self.checkTargetDeviceIsClaimed()
        } else if (self.context.targetDevice.isClaimed == false && self.context.targetDevice.claimCode == nil) {
            self.getClaimCode()
        } else if (self.context.targetDevice.isClaimed == true || self.context.targetDevice.claimCode != nil) {
            self.stepCompleted()
        }
    }

    private func getDeviceId() {
        self.context.targetDevice.transceiver!.sendGetDeviceId { result, deviceId in
            self.log("targetDevice.didReceiveDeviceIdReply: \(result.description()), deviceId: \(deviceId as Optional)")
            if (self.context.canceled) {
                return
            }
            if (result == .NONE) {
                self.context.targetDevice.deviceId = deviceId!
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceIsClaimed() {
        self.log("get devices list")
        ParticleCloud.sharedInstance().getDevices { devices, error in
            if (self.context.canceled) {
                return
            }

            self.log("get devices completed")

            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.context.targetDevice.deviceId!) {
                        self.log("device belongs to user already")
                        self.context.targetDevice.name = device.name
                        self.context.targetDevice.isClaimed = true
                        self.context.targetDevice.claimCode = nil
                        self.stepCompleted()
                        return
                    }
                }
            }

            self.context.targetDevice.isClaimed = false
            self.context.targetDevice.claimCode = nil
            self.start()
        }
    }

    private func getClaimCode() {
        log("generating claim code")
        ParticleCloud.sharedInstance().generateClaimCode { claimCode, userDevices, error in
            if (self.context.canceled) {
                return
            }

            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            self.log("claim code generated")
            self.context.targetDevice.claimCode = claimCode
            self.stepCompleted()
        }
    }

}
