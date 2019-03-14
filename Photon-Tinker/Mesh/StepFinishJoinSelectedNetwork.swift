//
// Created by Raimundas Sakalauskas on 2019-03-09.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepFinishJoinSelectedNetwork: MeshSetupStep {

    private var networkJoinedInAPI: Bool = false

    override func start() {
        guard let context = self.context else {
            return
        }

        if (!networkJoinedInAPI) {
            self.joinNetworkInAPI()
        } else if (context.commissionerDevice?.isCommissionerMode ?? false) {
            self.stopCommissioner()
        } else if (context.targetDevice.isSetupDone == nil || context.targetDevice.isSetupDone == false) {
            self.setTargetDeviceSetupDone()
        } else if (context.targetDevice.isListeningMode == nil || context.targetDevice.isListeningMode == true) {
            self.stopTargetDeviceListening()
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        networkJoinedInAPI = false
    }

    private func joinNetworkInAPI() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().addDevice(context.targetDevice.deviceId!, toNetwork: context.targetDevice.meshNetworkInfo!.networkID) {
            [weak self, weak context] error in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("addDevice error: \(error as Optional)")

            guard error == nil else {
                self.fail(withReason: .UnableToJoinNetwork, nsError: error)
                return
            }

            self.networkJoinedInAPI = true
            self.start()
        }
    }

    private func stopCommissioner() {
        guard let context = self.context else {
            return
        }

        context.delegate.meshSetupDidEnterState(self, state: .JoiningNetworkStep2Done)

        /// NOT_ALLOWED: The client is not authenticated
        context.commissionerDevice!.transceiver!.sendStopCommissioner {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendStopCommissioner: \(result.description())")

            if (result == .NONE) {
                context.commissionerDevice?.isCommissionerMode = false
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
         }
    }

    private func setTargetDeviceSetupDone() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendDeviceSetupDone (done: true) {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendDeviceSetupDone: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isSetupDone = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func stopTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendStopListening {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStopListening: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isListeningMode = false
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
