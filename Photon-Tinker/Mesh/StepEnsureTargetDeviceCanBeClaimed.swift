//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureTargetDeviceCanBeClaimed: MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.deviceId == nil) {
            self.getDeviceId()
        } else if (context.targetDevice.isClaimed == nil) {
            self.checkTargetDeviceIsClaimed()
        } else if (context.targetDevice.isClaimed == false && context.targetDevice.claimCode == nil) {
            self.getClaimCode()
        } else if (context.targetDevice.isClaimed == true || context.targetDevice.claimCode != nil) {
            self.stepCompleted()
        }
    }

    private func getDeviceId() {
        context?.targetDevice.transceiver!.sendGetDeviceId { [weak self, weak context] result, deviceId in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.didReceiveDeviceIdReply: \(result.description()), deviceId: \(deviceId as Optional)")

            if (result == .NONE) {
                context.targetDevice.deviceId = deviceId!
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceIsClaimed() {
        self.log("get devices list")
        ParticleCloud.sharedInstance().getDevices { [weak self, weak context] devices, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("get devices completed")

            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == context.targetDevice.deviceId!) {
                        self.log("device belongs to user already")
                        context.targetDevice.name = device.name
                        context.targetDevice.isClaimed = true
                        context.targetDevice.claimCode = nil
                        self.stepCompleted()
                        return
                    }
                }
            }

            context.targetDevice.isClaimed = false
            context.targetDevice.claimCode = nil
            self.start()
        }
    }

    private func getClaimCode() {
        log("generating claim code")
        ParticleCloud.sharedInstance().generateClaimCode { [weak self, weak context] claimCode, userDevices, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            self.log("claim code generated")
            context.targetDevice.claimCode = claimCode
            self.stepCompleted()
        }
    }

}
